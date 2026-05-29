# Quarkus Flow

**Domain tags:** `workflow` `ai` `serverless`  
**Version tracked:** quarkus-flow 0.x (pre-GA), CNCF Serverless Workflow spec v0.8  
**Last reviewed:** 2026-05-29

---

## What It Is

quarkus-flow is Quarkus's implementation of the CNCF Serverless Workflow specification.
Workflows are CDI beans extending `Flow`, defined using FuncDSL (Java fluent API) or YAML.
Executes on Vert.x (reactive, non-blocking). Supports stateful multi-step orchestration,
human-in-the-loop (HITL) pauses, AI agent integration, event-driven coordination via
emit/listen, and HTTP task execution.

**Not Kogito.** quarkus-flow uses the CNCF Serverless Workflow SDK directly — the two are
unrelated despite both being Quarkus workflow options. See GE-20260414-5b3897.

---

## When to Use

- Multi-step processes with explicit state, branching, and loops
- AI agent orchestration with structured input/output
- Human-in-the-loop workflows (pause, notify, resume)
- Event-driven coordination between services
- **Don't use for:** simple async fire-and-forget → use `@Asynchronous`
- **Don't use for:** pure event streaming → use Quarkus Messaging / Kafka

---

## Key Documentation

| Resource | URL | What's there |
|----------|-----|-------------|
| Quarkiverse Hub | https://quarkiverse.github.io/quarkiverse-docs/quarkus-flow/dev/ | Main docs |
| CNCF Spec | https://serverlessworkflow.io/spec/latest | Underlying spec |
| CNCF Java SDK | https://github.com/serverlessworkflow/sdk-java | SDK source |
| FuncDSL source | https://github.com/quarkiverse/quarkus-flow | Implementation |

---

## Core Concepts

- **Flow** — base class; all workflows extend `io.quarkiverse.flow.Flow`, annotated `@ApplicationScoped`
- **descriptor()** — the method override where the workflow graph is defined; returns `Workflow`
- **FuncDSL** — Java fluent API for defining workflow tasks inline via static imports
- **WorkflowDefinition** — injectable handle for YAML-defined workflows (via `@Identifier`)
- **WorkflowModel** — the result type returned from `workflow.instance(...).start()`
- **emit / listen** — event-based task coordination; `emitJson` publishes, `listen` blocks until received
- **HITL** — Human-in-the-loop; workflow pauses at a `listen` task until an external signal resumes it
- **outputAs / exportAs** — `outputAs` transforms the task result only; `exportAs` merges into global workflow context
- **@Blocking** — annotate function tasks that do blocking I/O to avoid freezing the Vert.x event loop

---

## Workflow Structure

```java
import static io.serverlessworkflow.fluent.func.dsl.FuncDSL.*;
import static io.serverlessworkflow.fluent.func.spec.FuncWorkflowBuilder.workflow;

@ApplicationScoped
public class MyWorkflow extends Flow {
    @Override
    public Workflow descriptor() {
        return workflow("my-workflow")
            .tasks(/* ... */)
            .build();
    }
}
```

**Key imports:**
```java
import io.serverlessworkflow.api.types.Workflow;
import io.serverlessworkflow.fluent.func.spec.FuncWorkflowBuilder;
import static io.serverlessworkflow.fluent.func.dsl.FuncDSL.*;
import static io.serverlessworkflow.fluent.func.spec.FuncWorkflowBuilder.workflow;
```

**Inject workflows:**
```java
@Inject MyWorkflow workflow;                              // Java DSL workflow

@Inject @Identifier("flow:echo-name")                   // YAML workflow
WorkflowDefinition definition;
```

---

## FuncDSL Quick Reference

| Pattern | Example |
|---------|---------|
| Function call | `function(svc::process, Request.class)` |
| Named task | `function("step1", svc::process, Request.class)` |
| AI agent | `agent("drafter", ai::draft, String.class)` |
| Data extraction | `.inputFrom("$.cart.items")` |
| Result transform | `.outputAs("{ status: ., processed: true }")` |
| Context merge | `.exportAs((result, ctx) -> merge(result, ctx), Type.class)` |
| Branching | `switchWhenOrElse(pred, "yesStep", "noStep", Type.class)` |
| Emit event | `emitJson("org.acme.event.type", Data.class)` |
| Wait for event | `listen("wait", toOne("org.acme.done"))` |
| HTTP call | `get("https://api.example.com/resource")` |
| Iteration | `forEach(ctx -> ctx.items(), inner -> ...)` |
| Side effect | `consume("log", data -> logger.info(...), Type.class)` |

**Rule:** name tasks you branch to. Keep transformations close to the task that needs them.

---

## HITL Pattern

```java
workflow("review-loop")
    .tasks(
        agent("draftAgent", drafter::draft, String.class)
            .inputFrom("$.seedPrompt")
            .exportAs("{ draft: . }"),

        emitJson("org.acme.review.required", Draft.class),

        listen("waitHuman", toOne("org.acme.review.done"))
            .outputAs((Collection<Object> c) -> c.iterator().next()),

        switchWhenOrElse(
            (HumanReview h) -> h.needsRevision(),
            "draftAgent",
            "finalizeStep",
            HumanReview.class
        ),

        consume("finalizeStep",
            (HumanReview r) -> mailService.send("out@acme.com", "Done", r.draft()),
            HumanReview.class
        )
    )
    .build()
```

---

## Testing Patterns

**Unit test (inject and execute):**
```java
@QuarkusTest
class MyWorkflowTest {
    @Inject MyWorkflow workflow;

    @Test
    void should_complete() throws Exception {
        WorkflowModel result = workflow.instance(Map.of("input", "value"))
            .start().toCompletableFuture().get(5, TimeUnit.SECONDS);
        assertThat(result.asMap().orElseThrow().get("output")).isEqualTo("expected");
    }
}
```

**YAML workflow test:**
```java
@Inject @Identifier("flow:echo-name") WorkflowDefinition definition;
```

**REST integration (REST Assured):**
```java
given().queryParam("name", "John").when().get("/endpoint")
    .then().statusCode(200).body("message", equalTo("Hello, John!"));
```

**Mock AI agents** — always mock LangChain4j services in tests:
```java
@InjectMock MyAIService aiService;
// then: when(aiService.generate(any())).thenReturn("deterministic response");
```

**Enable tracing in tests:**
```properties
%test.quarkus.flow.tracing.enabled=true
```

**JAX-RS resource must be reactive** (return `Uni` or `CompletionStage`) for automatic
RFC 7807 error mapping to work. Blocking with `.await().indefinitely()` wraps exceptions
in `ExecutionException` and breaks the mapper.

---

## Observability

**Structured JSON logging:**
```properties
quarkus.log.console.json.enabled=true
%dev.quarkus.log.console.json.enabled=false
%test.quarkus.log.console.json.enabled=false
```

**MDC fields emitted by quarkus-flow:**

| MDC Key | Example | When |
|---------|---------|------|
| `quarkus.flow.instanceId` | `01K9GDCXJVN89V0N4CWVG40R7C` | Always |
| `quarkus.flow.event` | `workflow.started`, `task.failed` | Always |
| `quarkus.flow.task` | `fetchCaseData` | Task events |
| `quarkus.flow.taskPos` | `do/0/fetchCaseData` | Task events |

**Enable workflow tracing:**
```properties
quarkus.flow.tracing.enabled=true
%dev.quarkus.flow.tracing.enabled=false
```

**HTTP header propagation** (automatic to downstream services):

| Header | MDC Field |
|--------|-----------|
| `X-Flow-Instance-Id` | `quarkus.flow.instanceId` |
| `X-Flow-Task-Id` | `quarkus.flow.taskPos` |

**OpenTelemetry:**
```xml
<dependency>
  <groupId>io.quarkus</groupId>
  <artifactId>quarkus-opentelemetry</artifactId>
</dependency>
```
```properties
quarkus.otel.exporter.otlp.endpoint=http://localhost:4317
quarkus.otel.resource.attributes=service.name=myapp
%dev.quarkus.otel.sdk.disabled=true
%test.quarkus.otel.sdk.disabled=true
```

**quarkus-flow built-in metrics** (auto-exposed when Micrometer on classpath):

| Metric | Type |
|--------|------|
| `quarkus_flow_workflow_started_total` | Counter |
| `quarkus_flow_workflow_completed_total` | Counter |
| `quarkus_flow_workflow_failed_total` | Counter |
| `quarkus_flow_task_duration_seconds` | Histogram |

---

## Common Pitfalls

| Mistake | Why It's Wrong | Fix |
|---------|----------------|-----|
| Unnamed task used as branch target | `switchWhen*` requires a task name to resolve | Name tasks you branch to |
| Blocking in `function` task without `@Blocking` | Freezes Vert.x I/O thread | Annotate with `@Blocking` or use `executeBlocking` |
| `outputAs` when you mean `exportAs` | Wrong scope — `outputAs` is task-local, `exportAs` merges to global context | Check whether you need task or global scope |
| Forgetting `@Identifier` on YAML workflow injection | CDI can't resolve bean | Add `@Identifier("flow:namespace:name")` |
| Blocking REST resource (`.await().indefinitely()`) | Wraps exceptions in `ExecutionException`, breaks RFC 7807 error mapping | Return `Uni` or `CompletionStage` |
| Mutable shared state in `Flow` subclass | `@ApplicationScoped` is shared across instances — race conditions | Treat Flow beans as stateless; all state in workflow context |
| Calling real LLM in tests | Flaky, slow, non-deterministic | Use `@InjectMock` or stub CDI beans |
| Plain mutable POJO as workflow input | `FAIL_ON_EMPTY_BEANS` at runtime | See GE-0069 |
| Using `consume` steps expecting mutable propagation | `consume` steps re-deserialize input — mutations don't propagate | See GE-0068 |
| `listen` task expecting SmallRye in-memory channel | `listen` doesn't receive from SmallRye in-memory | See GE-0070 / GE-0071 for bridge pattern |

---

## Garden Entries

Gotchas and techniques already captured:

- [GE-20260414-5b3897 quarkus-flow uses CNCF SDK directly — not Kogito](../quarkus/GE-20260414-5b3897.md)
- [GE-20260414-10d4da CallableTaskBuilder.accept(Class) cannot distinguish custom callable names](../quarkus/GE-20260414-10d4da.md)
- [GE-20260414-5fc8e0 CallableTaskBuilder SPI — exact interface signatures (v7.13)](../quarkus/GE-20260414-5fc8e0.md)
- [GE-20260414-14d244 TaskExecutorFactory SPI — undocumented extension point](../quarkus/GE-20260414-14d244.md)
- [GE-0068 consume steps re-deserialize input — mutations don't propagate](../quarkus/GE-0068.md)
- [GE-0069 plain mutable POJO as workflow input → FAIL_ON_EMPTY_BEANS](../quarkus/GE-0069.md)
- [GE-0070 listen task does not receive from SmallRye in-memory channels](../quarkus/GE-0070.md)
- [GE-0071 Bridge SmallRye in-memory channel to Quarkus Flow via @Incoming + startInstance()](../quarkus/GE-0071.md)
- [GE-0168 Quarkus Flow discovers workflows from YAML files and Java classes at build time](../quarkus/GE-0168.md)

---

## See Also

- [approaches/observability.md](../approaches/observability.md) — observability concepts (three pillars, MDC, tracing, metrics)
- [approaches/observability-patterns.md](../approaches/observability-patterns.md) — implementation patterns and production checklist

---

## Known Gaps

- [ ] YAML workflow definition syntax and schema reference
- [ ] Workflow versioning and migration patterns
- [ ] Error handling and compensation patterns
- [ ] Performance at scale / throughput benchmarks
- [ ] quarkus-flow + quarkus-work integration patterns
