**Type:** technique
**Submission ID:** GE-0105
**Date:** 2026-04-08
**Project:** starcraft
**Labels:** #strategy, #pattern, #performance

---

## Drools as Action Compiler for GOAP — One Session per Tick, Not per A* Node

### Stack
Drools Rule Units (drools-ruleunits-api, any version), GOAP / A* planning, Java

### What Most Developers Would Do
When integrating Drools with A* search, the instinctive approach is to call Drools
at each search node to evaluate which actions are applicable given the current
hypothetical WorldState. This requires either cloning the Drools session per node
(expensive, complex) or resetting and re-inserting facts per node (also expensive).

### The Non-Obvious Approach
Fire Drools **once per tick** on the real game state to produce a static list of
`GoapAction` objects — each carrying preconditions, effects, and cost as plain Java
data. Then run A* entirely over pure-Java `WorldState` clones using that action list.
Drools is not involved during the search at all.

```java
// Step 1: Drools fires once — produces action library
TacticsRuleUnit data = buildRuleUnit(army, enemies, strategyGoal);
try (RuleUnitInstance<TacticsRuleUnit> instance = ruleUnit.createInstance(data)) {
    instance.fire();
}
List<GoapAction> actions = parseActions(data.getActionDecisions()); // plain Java

// Step 2: A* searches using action library — no Drools involvement
for (UnitGroup group : parseGroups(data.getGroupDecisions())) {
    List<GoapAction> plan = planner.plan(group.worldState(), group.goal(), actions);
    dispatch(plan, group);
}

// WorldState cloning is cheap — pure Java record
record WorldState(Map<String, Boolean> conditions) {
    WorldState with(String key, boolean value) {
        var copy = new HashMap<>(conditions);
        copy.put(key, value);
        return new WorldState(copy);
    }
}
```

### Why This Works
- **Decoupled at the `GoapAction` boundary** — Drools produces a declarative action
  library; A* consumes it. Neither knows about the other.
- **One session per tick** — not one session per A* node. For a group of 10 units
  with a 3-action vocabulary, A* explores O(3^depth) nodes; Drools fires O(1).
- **WorldState cloning is cheap** — a `Map<String, Boolean>` copy at each A* node
  costs nanoseconds; cloning a Drools session costs orders of magnitude more.
- **Hot-reloadable action library** — because actions are defined in DRL, you can
  change the action vocabulary (add `Kite`, `Flank`, adjust costs) without touching
  the planner.

### When to Apply
Any system where a rule engine defines a planning action space and you need
cost-optimal paths through it. The key condition: actions can be represented as
(preconditions, effects, cost) triples that are stable for the duration of one
planning cycle. Works for game AI, workflow automation, and robotic planning.

### Alternatives Considered
- **Drools as forward-chaining planner** — insert WorldState + goal as facts, let
  rules fire to achieve the goal. Elegant but greedy (salience-ordered, not
  cost-optimal). Breaks down when multiple paths exist with different costs.
- **Drools as per-node oracle** — call Drools at each A* node. Architecturally
  clean but requires session state management per node; impractical at planning depth.

---

*Score: 13/15 · Included because: genuinely non-obvious — devs reach for per-node Drools; decoupled boundary is elegant and reusable · Reservation: pattern is theoretical at time of submission (not yet implemented)*

**Suggested target:** `drools/drools-goap-planning.md` (new file)
*File header:* `# Drools — Gotchas and Techniques`

**Light duplicate check:** No existing Drools or GOAP entries found in GARDEN.md index.
**IDs scanned:** none (no Drools/GOAP entries present in index).
