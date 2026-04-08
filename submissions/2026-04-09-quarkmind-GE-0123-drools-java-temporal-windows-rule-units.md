**Date:** 2026-04-09
**Submission ID:** GE-0123
**Type:** technique
**Title:** Use Java-managed event buffers + fresh RuleUnitInstance per tick instead of Drools Fusion STREAM mode for temporal CEP in Quarkus rule units
**Stack:** Drools 10 (Apache KIE), Quarkus
**Labels:** #pattern, #drools

## Symptom / Context
Implementing temporal pattern detection (e.g. "≥6 ROACH units seen in a 3-minute window") using Drools rule units in a Quarkus application. The natural Drools CEP approach — `window:time()` in DRL with STREAM event processing mode — requires `KieSession` and `kmodule.xml` configuration, which conflicts with the `drools-quarkus` extension's rule unit model. Attempting to use `window:time()` operators in rule unit DRL causes compilation errors or silent rule failures.

## Root Cause
The `drools-quarkus` extension uses the Drools rule unit model (`RuleUnitData`, `RuleUnitInstance`), which is stateless by design — a fresh instance is created per invocation. Drools Fusion temporal operators (`window:time()`, `window:length()`, `over window:time()`) require STREAM event processing mode, which requires a persistent `KieSession` with clock management. These two approaches are architecturally incompatible in the current `drools-quarkus` extension. This incompatibility is not documented anywhere in the Quarkus or Drools documentation.

A second problem: even if you work around STREAM mode, Drools' RETE network does not re-fire rules for facts that haven't changed. If you maintain a persistent `RuleUnitInstance` and insert the same scouting events each tick, the rules fire once and never again — a silent failure that is hard to diagnose.

## Fix / Technique
Maintain Java-side `Deque<TimestampedEvent>` buffers per event type. Each tick:

1. Insert new events into the deque.
2. Evict expired events: `buffer.removeIf(e -> currentTime - e.timestamp() > windowMs)`.
3. Build a fresh `ScoutingRuleUnit` (or equivalent `RuleUnitData`) from the current buffer contents.
4. Fire a new `RuleUnitInstance` — discard it after firing.

The DRL rules become simple accumulators — no temporal operators needed:

```java
// Java side — per tick
public void tick(long currentTimeMs) {
    // 1. insert new events
    newEvents.forEach(roachBuffer::addLast);
    // 2. evict expired
    roachBuffer.removeIf(e -> currentTimeMs - e.timestamp() > THREE_MINUTES_MS);
    // 3. build rule unit from current window
    ScoutingRuleUnit unit = new ScoutingRuleUnit(List.copyOf(roachBuffer), currentTimeMs);
    // 4. fire and discard
    RuleUnitProvider.get().createRuleUnitInstance(unit).fire();
}
```

```drl
// DRL — pure accumulator, no temporal operators
rule "Heavy Roach pressure"
when
    $unit: /scoutingContext
    accumulate(
        $e: /roachSightings,
        $count: count($e);
        $count >= 6
    )
then
    $unit.addThreat(ThreatLevel.HIGH, "Heavy Roach pressure: " + $count + " sightings");
end
```

The temporal window logic lives in Java (easy to unit test with a mock clock). The Drools rules remain stateless accumulators that see only the events currently within the window.

**Testing:** The Java buffer + eviction logic is plain Java — test it with `assertEquals`. The rule unit receives a snapshot list — test it with a standard `@QuarkusTest`. No need to test temporal behaviour inside Drools at all.

## Why Non-Obvious
Drools Fusion temporal operators (`window:time()`, CEP) are the documented and marketed Drools CEP approach. When implementing time-windowed detection with Drools, every Drools tutorial and the official documentation points to STREAM mode and `window:time()`. The `drools-quarkus` extension's incompatibility with STREAM mode is completely undocumented.

The Java buffer approach feels like "giving up on Drools CEP" — offloading temporal logic to Java when you have a CEP engine available. In practice it is cleaner: the temporal logic is trivially testable, the rules stay simple, and the fresh-instance-per-tick pattern sidesteps the RETE re-fire problem entirely.

The re-fire problem is a separate non-obvious trap: a persistent `KieSession` or `RuleUnitInstance` will not re-fire rules for facts that were already present. If your scouting event list doesn't change between ticks, rules that fired last tick will not fire again — silently. Creating a fresh `RuleUnitInstance` each tick avoids this entirely.

## Suggested target
`quarkus/drools-rule-units.md` (create if needed, header: `# Drools Rule Units Gotchas and Techniques`)

*Score: 13/15 · Included because: highly non-obvious; the incompatibility is completely undocumented; saves hours of failed experimentation with STREAM mode; the re-fire silent failure is a second independent trap; cross-project wherever Drools+Quarkus is used · Reservation: none identified*
