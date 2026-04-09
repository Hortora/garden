# Drools Rule Units — Gotchas and Techniques

---

## Phase 2 Rules Silently Don't Fire When Depending on List Mutated by Phase 1

**ID:** GE-0109
**Stack:** Drools Rule Units (drools-ruleunits-api, any version), multi-phase DRL rule sets

**Symptom:** Phase 2 rules (lower salience) that depend on state produced by Phase 1 rules (higher salience) never fire, even though Phase 1 ran correctly. No error is thrown. The output list from Phase 2 stays empty. Everything compiles and boots without warning.

**Context:** A two-phase DRL design where Phase 1 rules (salience 200+) classify facts and write decisions to a plain `List<String>` field on the RuleUnitData, and Phase 2 rules (salience 100+) try to react to those decisions using `eval(list.stream().anyMatch(...))` in their LHS.

Phase 1 fires first (higher salience), adds strings to the list. Phase 2 rules are already on the agenda — their `eval()` conditions were evaluated against the list *before Phase 1 fired*, when it was empty. Drools does not re-evaluate agenda items when a plain Java `List` is mutated; it only re-evaluates when a `DataStore` changes.

### What was tried (didn't work)
- Using `eval()` in Phase 2 LHS to check the list — silently fails
- Increasing salience gap between phases — no effect

### Root cause
Drools Rule Unit re-evaluation is triggered only by changes to `DataStore` fields. Plain Java `List` mutations are invisible to the Drools agenda — it has no hook into standard Java collections. A rule whose LHS was evaluated to `false` before Phase 1 fired will never be reconsidered unless the agenda is explicitly retriggered, which `List.add()` does not do.

### Fix
Phase 1 rules insert group IDs into a dedicated `DataStore<String>` field (`activeGroups`) in addition to (or instead of) writing to the `List<String>`. Phase 2 rules then pattern-match on the `DataStore`:

```java
// TacticsRuleUnit — add a DataStore for inter-phase signalling
private final DataStore<String> activeGroups = DataSource.createStore();
public DataStore<String> getActiveGroups() { return activeGroups; }
```

```drl
// Phase 1 — inserts into DataStore (triggers re-evaluation)
rule "Group: low health"
    salience 210
when
    eval(strategyGoal.equals("ATTACK"))
    $u: /army[ (double) this.health() / this.maxHealth() < 0.3 ]
then
    groupDecisions.add("low-health:UNIT_SAFE:" + $u.tag());
    activeGroups.add("low-health");  // <-- signals Phase 2
end

// Phase 2 — matches on DataStore (fires correctly after Phase 1)
rule "Action: Retreat available"
    salience 110
when
    /activeGroups[ this == "low-health" ]  // <-- NOT eval(groupDecisions.stream()...)
then
    actionDecisions.add("RETREAT:1");
end
```

`DataStore.add()` notifies the Drools agenda — Phase 2 rules are reconsidered and fire correctly.

### Why non-obvious
Multi-phase Drools designs naturally use a shared `List<String>` for communication (same pattern as the output lists that work fine after `fire()` completes). The distinction — List mutations are invisible to the agenda, DataStore insertions are not — is not prominently documented. The failure is completely silent: rules compile, the session fires, Phase 1 runs, Phase 2 produces nothing.

*Score: 12/15 · Included because: silent failure + misleading symptom; affects any multi-phase Rule Unit design · Reservation: none*

---
