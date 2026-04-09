# Drools Rule Units in Quarkus — Gotchas and Techniques

---

## Use Java-Managed Event Buffers + Fresh RuleUnitInstance per Tick Instead of Drools Fusion STREAM Mode for Temporal CEP in Quarkus Rule Units

**ID:** GE-0123
**Stack:** Drools 10 (Apache KIE), Quarkus
**Labels:** `#pattern` `#drools`
**What it achieves:** Implements temporal pattern detection (e.g. "≥6 events seen in a 3-minute window") in a Quarkus rule unit application without the `KieSession`/STREAM mode incompatibility that breaks `drools-quarkus`.
**Context:** Any Quarkus application using `drools-quarkus` rule units that needs time-windowed event pattern detection, where the natural Drools CEP approach (STREAM mode, `window:time()`) conflicts with the stateless rule unit model.

### The problem
The natural Drools CEP approach — `window:time()` in DRL with STREAM event processing mode — requires `KieSession` and `kmodule.xml` configuration, which conflicts with the `drools-quarkus` extension's rule unit model. Attempting to use `window:time()` operators in rule unit DRL causes compilation errors or silent rule failures.

Root cause: `drools-quarkus` uses the rule unit model (`RuleUnitData`, `RuleUnitInstance`), which is stateless by design — a fresh instance is created per invocation. Drools Fusion temporal operators require a persistent `KieSession` with clock management. These two approaches are architecturally incompatible. **This incompatibility is not documented anywhere in the Quarkus or Drools documentation.**

A second trap: even if you work around STREAM mode, Drools' RETE network does not re-fire rules for facts that haven't changed. If you maintain a persistent `RuleUnitInstance` and insert the same events each tick, rules fire once and never again — a silent failure.

### The technique
Maintain Java-side `Deque<TimestampedEvent>` buffers per event type. Each tick: insert new events, evict expired events, build a fresh `RuleUnitData` from the current buffer, fire and discard.

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
// DRL — pure accumulator, no temporal operators needed
rule "Heavy pressure"
when
    $unit: /scoutingContext
    accumulate(
        $e: /sightings,
        $count: count($e);
        $count >= 6
    )
then
    $unit.addThreat(ThreatLevel.HIGH, "Heavy pressure: " + $count + " sightings");
end
```

The temporal window logic lives in Java (trivially unit-testable with a mock clock). The Drools rules remain stateless accumulators that see only the events currently within the window. The fresh-instance-per-tick pattern also sidesteps the RETE re-fire problem entirely.

### Why this is non-obvious
Drools Fusion temporal operators (`window:time()`, CEP) are the documented and marketed Drools CEP approach. Every Drools tutorial and the official documentation points to STREAM mode and `window:time()` for time-windowed detection. The `drools-quarkus` extension's incompatibility with STREAM mode is completely undocumented.

The Java buffer approach feels like "giving up on Drools CEP" — offloading temporal logic to Java when you have a CEP engine available. In practice it is cleaner: the temporal logic is trivially testable, the rules stay simple, and the fresh-instance-per-tick pattern sidesteps the RETE re-fire problem entirely.

*Score: 13/15 · Included because: highly non-obvious; the incompatibility is completely undocumented; saves hours of failed experimentation with STREAM mode; the re-fire silent failure is a second independent trap · Reservation: none identified*

---
