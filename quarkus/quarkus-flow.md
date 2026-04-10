# Quarkus Flow Gotchas and Techniques

---

## Quarkus Flow `consume` steps re-deserialize input — mutable mutations don't propagate

**ID:** GE-0068
**Stack:** `io.quarkiverse.flow:quarkus-flow:0.7.1`, Quarkus 3.34.2, FuncDSL `consume` tasks
**Symptom:** State changes made to a mutable workflow input object in one `consume` step are invisible to the next step. The object appears unchanged in every step.
**Context:** A `Flow` subclass with a `descriptor()` that chains multiple `consume(service::method, InputType.class)` steps, where `InputType` is a mutable class with methods that modify internal state. Step 1 calls `spend(100)` — step 2 still sees the original value.

### What was tried

Verifying the service method logic directly (correct), checking CDI scope (not the issue), logging inside each step (confirmed the mutation happens but is invisible to the next step).

### Root cause

Quarkus Flow serializes the workflow input to JSON and deserializes it freshly for each `consume` step. Each step receives an independent copy of the original input, not the output of the previous step. Mutations written in step N are not carried forward.

### Solution 1 — Use immutable records; design steps to be independent

**Approach:** Replace mutable input with an immutable Java record. Since each step gets its own deserialised copy anyway, design each step to make decisions based on the original input — no cross-step arbitration.
**Pros:** Clean workflow design; each step is stateless and independently testable; no shared-state coupling.
**Cons/trade-offs:** Requires redesigning step logic to not depend on prior-step mutations; not feasible when steps must genuinely see each other's effects (e.g. budget arbitration across multiple decisions).

```java
// BAD — budget.spendMinerals(100) in checkSupply is invisible to checkProbes
return workflow("my-flow")
    .tasks(
        consume(svc::checkSupply,    MutableInput.class),  // spends 100, but...
        consume(svc::checkProbes,    MutableInput.class),  // sees original 200, not 100
        consume(svc::checkGas,       MutableInput.class),  // sees original 200, not 100
        consume(svc::checkExpansion, MutableInput.class)
    ).build();

// GOOD — use an immutable record; each step reads original state independently
public record ImmutableTick(int minerals, List<Unit> workers) {}
```

### Solution 2 — Merge sequential consume() steps into a single step

**Approach:** Collapse all sequential `consume()` steps that share mutable state into one `consume()` step that calls each method in sequence.
**Pros:** Works with mutable objects; simplest fix when steps must share state; one budget object shared across all calls; no serialisation boundary between them.
**Cons/trade-offs:** Loses workflow-level visibility into individual step progress; all-or-nothing execution (no checkpointing between merged steps).

```java
// Before — four steps, budget reset between each:
.tasks(
    consume(decisions::checkSupply,    GameStateTick.class),
    consume(decisions::checkProbes,    GameStateTick.class),
    consume(decisions::checkGas,       GameStateTick.class),
    consume(decisions::checkExpansion, GameStateTick.class)
)

// After — one step, one budget shared across all calls:
.tasks(
    consume(decisions::checkAll, GameStateTick.class)
)
```

Where `checkAll` simply calls the four methods in order:

```java
public void checkAll(GameStateTick tick) {
    checkSupply(tick);
    checkProbes(tick);
    checkGas(tick);
    checkExpansion(tick);
}
```

**Symptom that surfaced this:** Budget overcommitting — 110 minerals, but both Pylon (100) and Probe (50) were queued because each step saw the original 110. Regression test: hand the workflow 110 minerals with conditions triggering two decisions; assert `intentQueue.pending().hasSize(1)`.

### Why non-obvious

The FuncDSL reads as a sequential Java method-call pipeline — nothing in the API signals that serialization/deserialization happens between steps. The symptom is silent: if each step is given enough budget independently, tests pass, but cross-step arbitration silently fails. No warning is logged.

*Score: 14/15 · Included because: silent failure with no error, affects any flow using mutable input, took multiple failed approaches to diagnose · Reservation: only verified on 0.7.1*

---

## Quarkus Flow: plain mutable POJO as workflow input → `FAIL_ON_EMPTY_BEANS` at runtime

**ID:** GE-0069
**Stack:** `io.quarkiverse.flow:quarkus-flow:0.7.1`, Quarkus 3.34.2, Jackson ObjectMapper
**Symptom:** Starting a workflow instance with a plain mutable Java class (no Jackson annotations) throws at runtime:

```
com.fasterxml.jackson.databind.exc.InvalidDefinitionException:
No serializer found for class com.example.MyInput and no properties discovered
to create BeanSerializer (to avoid exception, disable SerializationFeature.FAIL_ON_EMPTY_BEANS)
```

The error occurs when the workflow engine tries to serialize the input between `consume` steps. The application boots fine — error only surfaces at flow execution time when the first `consume` step fires.

**Context:** Calling `flow.instance(myPlainPojoInput).start()` or `startInstance(myInput)` where `myInput` is a plain Java class with private fields and no Jackson annotations.

### Root cause

Quarkus Flow uses Jackson to serialize/deserialize the workflow input between `consume` steps (see GE-0068). A plain mutable class with private fields and no public getters or Jackson annotations cannot be serialized by Jackson's default configuration.

### Fix

```java
// Option 1 (best): Use an immutable Java record — Jackson handles records natively
public record MyInput(int minerals, int supplyUsed, List<Unit> workers) {}

// Option 2: Annotate the class for field-level visibility
@JsonAutoDetect(fieldVisibility = JsonAutoDetect.Visibility.ANY)
public class MyInput {
    private int minerals;
    private int supplyUsed;
}

// Option 3: Add @JsonCreator + @JsonProperty on all constructor parameters
public class MyInput {
    @JsonCreator
    public MyInput(
        @JsonProperty("minerals") int minerals,
        @JsonProperty("supplyUsed") int supplyUsed
    ) { ... }
}
```

### Why non-obvious

The error doesn't surface at compile time, at Quarkus boot, or at `startInstance()` — it surfaces only when the workflow engine first tries to serialize the input between steps. Nothing in the quarkus-flow documentation (0.7.1) mentions that workflow inputs must be Jackson-serializable. Developers unfamiliar with the internal serialization model will look for CDI or API misuse before reaching the Jackson angle.

*Score: 14/15 · Included because: runtime-only failure with misleading timing, no documentation, affects all quarkus-flow users passing custom objects · Reservation: only verified on 0.7.1*

---

## Quarkus Flow `listen` task does not receive from SmallRye in-memory channels

**ID:** GE-0070
**Stack:** `io.quarkiverse.flow:quarkus-flow:0.7.1`, Quarkus 3.34.2, SmallRye Reactive Messaging
**Symptom:** A `Flow` subclass with `listen("tick", toOne("org.acme.example.tick"))` in its `descriptor()` never fires when a `MutinyEmitter<MyType>` emits on a SmallRye in-memory channel. No error is thrown. The workflow is silently idle.
**Context:** Attempting to wire a SmallRye `@Channel("my-channel") MutinyEmitter<MyType>` to a Quarkus Flow workflow using the FuncDSL `listen` task.

### Root cause

The `listen` task in Quarkus Flow (CNCF Serverless Workflow spec) subscribes to CloudEvents, not to SmallRye Reactive Messaging channels. The `toOne("org.acme.example.tick")` string is a CloudEvent type, not a channel name. SmallRye in-memory channels carry plain Java objects — they are not CloudEvents and cannot be received by the `listen` task without additional CloudEvent wrapping infrastructure.

### Fix

Bridge SmallRye to the Flow engine using `@Incoming` + `startInstance()` directly on the `Flow` subclass. See GE-0071.

```java
// BROKEN — listen() doesn't receive from SmallRye in-memory @Channel
@Override
public Workflow descriptor() {
    return workflow("my-flow")
        .tasks(
            listen("tick", toOne("org.acme.example.tick")),  // never fires
            ...
        ).build();
}
```

### Why non-obvious

The quarkus-flow documentation and FuncDSL skill show `listen` as a standard reactive task. Nothing indicates it requires CloudEvent format specifically. The failure is silent — no error, no log, the flow just never starts. Developers naturally try the `listen` task first when integrating with SmallRye messaging.

*Score: 13/15 · Included because: silent failure, non-obvious CloudEvent requirement, affects the primary integration pattern developers will attempt · Reservation: only verified on 0.7.1 with in-memory connector*

---

## Bridge SmallRye in-memory channel to Quarkus Flow using @Incoming + startInstance()

**ID:** GE-0071
**Stack:** `io.quarkiverse.flow:quarkus-flow:0.7.1`, Quarkus 3.34.2, SmallRye Reactive Messaging
**Labels:** `#pattern` `#integration`
**What it achieves:** Drives a Quarkus Flow `Flow` subclass from a SmallRye `MutinyEmitter<T>` in-memory channel, without CloudEvent infrastructure or Kafka.
**Context:** You have a `@Channel("my-channel") MutinyEmitter<T>` and want to trigger a per-message FuncDSL workflow pipeline.

### The technique

Declare an `@Incoming` method directly on the `Flow` subclass. In the method body, call `startInstance(payload).replaceWithVoid()` to launch a per-message workflow instance:

```java
@ApplicationScoped
public class MyFlow extends Flow {

    @Inject MyService service;

    @Override
    public Workflow descriptor() {
        return workflow("my-flow")
            .tasks(
                consume(service::stepOne, MyInput.class),
                consume(service::stepTwo, MyInput.class),
                consume(service::stepThree, MyInput.class)
            ).build();
    }

    // Bridge: SmallRye in-memory → Flow engine
    @Incoming("my-channel")
    public Uni<Void> processTick(MyInput input) {
        return startInstance(input).replaceWithVoid();
    }
}
```

This creates a per-message workflow instance — each message triggers a fresh, short-lived run of the `consume` pipeline. No CloudEvent infrastructure needed. SmallRye handles back-pressure naturally via `Uni<Void>`.

### Why non-obvious

The natural assumption is to use the FuncDSL `listen` task (see GE-0070 — it doesn't work for SmallRye in-memory). Combining `@Incoming` directly on the `Flow` subclass alongside `descriptor()` is not shown in the quarkus-flow documentation. Most developers would try to bridge via a separate CDI bean rather than adding `@Incoming` to the `Flow` itself.

**Trade-off:** Each message starts a fresh instance (not a long-lived stateful workflow). For per-message processing pipelines this is correct. For long-lived stateful flows that persist state across many messages, CloudEvent + Kafka integration is needed instead.

*Score: 13/15 · Included because: non-obvious combination of two separate Quarkus APIs; saves significant investigation time; the natural approach (listen task) silently fails · Reservation: only verified on 0.7.1*
