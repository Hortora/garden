**Submission ID:** GE-0157
**Target ID:** GE-0068
**Date:** 2026-04-09
**Project:** quarkmind
**Type:** revise
**Revision kind:** solution

## Revise: GE-0068 — Quarkus Flow consume steps re-deserialize input

**What's new:** A concrete, tested fix and a specific code example from a production bug (#15 in QuarkMind).

**The fix:** Collapse all sequential `consume()` steps that share mutable state into a single `consume()` step. The merged method calls each decision in sequence — no serialisation boundary, one budget object shared across all calls.

**Concrete example (EconomicsFlow before/after):**

Before (broken — four steps, budget reset between each):
```java
.tasks(
    consume(decisions::checkSupply,    GameStateTick.class),
    consume(decisions::checkProbes,    GameStateTick.class),
    consume(decisions::checkGas,       GameStateTick.class),
    consume(decisions::checkExpansion, GameStateTick.class)
)
```

After (fixed — one step, one budget):
```java
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

**Symptom that surfaced this:** Economics plugin overcommitting resources — 110 minerals, but both Pylon (100) and Probe (50) were queued because each step saw the original budget. Regression test: hand the workflow 110 minerals with conditions triggering two decisions; assert `intentQueue.pending().hasSize(1)`.
