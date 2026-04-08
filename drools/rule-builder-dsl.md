# Drools Rule Builder DSL

---

## extendsRule() is authoring-time deduplication — not a runtime inheritance mechanism

**Context:** Implementing a Drools-compatible rule builder DSL, or reasoning
about what extendsRule() does at runtime in the real Drools engine.
**Applies to:** Drools rule engine; any Drools-compatible rule builder DSL
implementation or sandbox.

### The approach

`extendsRule()` in the Drools rule builder DSL is purely a DSL authoring
convenience — it has no special runtime semantics. The Rete network performs
node sharing automatically regardless of how rules are authored.

When a child rule extends a base rule, the rule builder compiles a single
complete rule containing all of the base rule's patterns plus the child's own.
The Rete network's node-sharing then ensures shared patterns are represented
as shared beta nodes across all rules that contain them. The result is
**identical** to writing out the full pattern set in every child rule
independently — `extendsRule()` just avoids repeated authoring.

**Implication for sandbox/alternative DSL implementations:** the correct
approach is to inline the base rule's sources and filters into the child rule
at builder construction time. No special runtime concept is needed.

### Implementation (for a sandbox/alternative DSL)

```java
// extensionPoint() on JoinNSecond — captures the base RuleDefinition
public RuleExtendsPoint2<DS, A> extensionPoint() {
    return new RuleExtendsPoint2<>(this.rd);  // just holds the RuleDefinition
}

// extendsRule() — inlines base sources + filters into the child at build time
public <B> Join1First<END, DS, B> extendsRule(RuleExtendsPoint2<DS, B> ep) {
    RuleDefinition<DS> child = new RuleDefinition<>("child");
    ep.baseRd().copyInto(child);  // inline sources and filters — no runtime magic
    return new Join1First<>(end, child);
}
```

### Why a skilled developer might not find this naturally

A developer familiar with Java inheritance or dependency injection naturally
assumes `extendsRule()` has runtime semantics — that the engine defers
execution of shared patterns to avoid duplication at runtime. The surprising
insight is that node sharing in Rete is a structural property of the compiled
network, not of the DSL authoring model. The DSL's `extendsRule()` is a
pattern-copy mechanism at build time; the Rete compiler handles deduplication
separately. Knowing this, the sandbox implementation becomes trivial: just
copy sources and filters at construction time.

---

## `addParamsFact()` must be called at build time — silent wrong-fact extraction at runtime

**ID:** GE-0057
**Stack:** Permuplate Drools DSL sandbox (pre-1.0)
**Symptom:** When using `rule.run(ctx, paramsValue)` with a single-fact filter (`filterLatest`), the filter silently receives `params` as the fact instead of the actual latest joined fact. No error, no exception — wrong data, wrong result.
**Context:** Building a Drools DSL rule with params (via `ParametersFirst.params()`, `.param()`, or `.map()`) and then using a single-fact filter on a subsequent join.

### Root cause

`RuleDefinition.wrapPredicate()` captures `registeredFactCount = accumulatedFacts` at build time to determine which fact is "latest" for single-fact filters. The trim logic: if `factArity == 1 && registeredFactCount > 1`, extract `facts[registeredFactCount - 1]`. Since params are injected at runtime (not via `addSource()`), `accumulatedFacts` at build time is one lower than the actual runtime fact array length. The "latest" index points to params, not the last joined fact.

### Fix

Call `rd.addParamsFact()` in every params-entry method on `ParametersFirst` immediately after creating the `RuleDefinition`, before returning the chain builder. This increments `accumulatedFacts` by 1 at build time — matching what will actually be at `facts[0]` at runtime:

```java
// In ParametersFirst.params(), param(), list(), map():
RuleDefinition<DS> rd = new RuleDefinition<>(name);
rd.addParamsFact();  // ← must come first, before any addSource()
return new JoinBuilder.Join1First<>(null, rd);
```

`addParamsFact()` is a package-private method on `RuleDefinition`:

```java
void addParamsFact() {
    accumulatedFacts++;
}
```

### Why non-obvious

The fix is a build-time operation (incrementing a counter) for a problem that only manifests at runtime. The symptom (wrong fact in filter) gives no hint that the counter is wrong — it looks like the filter is broken or the join chain is misconfigured. The separation between when params are declared (build time) and when they are injected (run time) means there's no obvious connection between `addParamsFact()` and the runtime behaviour of `wrapPredicate()`.

*Score: 14/15 · Included because: build-time/runtime split causes silent wrong-result with no error · Reservation: none*
