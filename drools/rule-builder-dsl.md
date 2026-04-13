# Drools Rule Builder DSL

---


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
