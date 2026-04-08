# ocraft-s2client-bot Gotchas and Techniques

Non-obvious behaviours and patterns in the ocraft-s2client-bot Java library for StarCraft II bot development.

---

## ocraft `agent.debug()` NPEs if called outside `onStep()` — debug interface only initialised during game loop

**ID:** GE-0027
**Stack:** ocraft-s2client-bot 0.4.21
**Symptom:** Calling `agent.debug()` from any thread other than the ocraft game loop thread throws a `NullPointerException` with no meaningful message. The same code works correctly when called from within `onStep()`.
**Context:** Any code that needs to trigger SC2 debug API commands from outside the S2Agent's frame callback — e.g. a REST endpoint, a test, or a scheduled task.

### What was tried (didn't work)
- Calling `agent.debug().debugCreateUnit(...)` from a REST handler — NPE at `debug()`
- Calling from a `CompletableFuture` — NPE
- Calling immediately after `coordinator.startGame(...)` returns — NPE (game loop not yet running)

### Root cause
`S2Agent.debug()` accesses `Client.controlInterface` which is only initialised once the SC2 game loop has started and is actively running. The `controlInterface` is set up internally by ocraft during the first `coordinator.update()` call. Any call before that point — or from outside the game loop thread — returns null.

### Fix

Use a pending command queue in the `S2Agent` subclass. External callers enqueue `Runnable` lambdas; `onStep()` drains and executes them, then flushes with `sendDebug()`.

**See GE-0021** — the queue pattern is described there in full as a standalone technique.

### Why this is non-obvious
The NPE gives no hint that `debug()` has a threading/lifecycle restriction. The method exists on the object, compiles fine, and only fails at runtime with a null pointer to an internal field. Nothing in the ocraft documentation mentions that debug commands must be issued from within `onStep()`.

*Score: 13/15 · Included because: runtime NPE with no diagnostic information; fix requires understanding ocraft's internal lifecycle · Reservation: none identified*

---

## Queue debug commands as Runnables in the S2Agent for cross-thread execution in onStep()

**ID:** GE-0021
**Stack:** ocraft-s2client-bot 0.4.21
**Labels:** `#testing` `#pattern`
**What it achieves:** Allows external callers (REST handlers, test code, scenario runners) to trigger SC2 debug API commands safely without knowing about the onStep() threading restriction. Commands execute on the next SC2 game frame.
**Context:** Any system using the SC2 debug API where commands need to be triggered from outside the ocraft game loop thread. See GE-0027 for the gotcha this solves.

### The technique

Add a `ConcurrentLinkedQueue<Runnable>` to your `S2Agent` subclass. Expose an `enqueueDebugCommand(Runnable)` method for external callers. Drain and execute the queue in `onStep()`, then flush with `sendDebug()`:

```java
public class SC2BotAgent extends S2Agent {
    private final ConcurrentLinkedQueue<Runnable> pendingDebugCommands
        = new ConcurrentLinkedQueue<>();

    /** Safe to call from any thread — queues for next onStep() */
    public void enqueueDebugCommand(Runnable command) {
        pendingDebugCommands.add(command);
    }

    @Override
    public void onStep() {
        // Execute all queued debug commands (runs on game loop thread)
        Runnable cmd;
        boolean hadCommands = false;
        while ((cmd = pendingDebugCommands.poll()) != null) {
            cmd.run();
            hadCommands = true;
        }
        if (hadCommands) {
            debug().sendDebug(); // flush to SC2 once after all commands run
        }
        // ... rest of onStep observation/intent handling
    }
}

// External caller (REST endpoint, scenario runner, test):
agent.enqueueDebugCommand(() ->
    agent.debug().debugCreateUnit(Units.PROTOSS_ZEALOT, 2, Point2d.of(20f, 20f), 2));
agent.enqueueDebugCommand(() ->
    agent.debug().debugCreateUnit(Units.PROTOSS_STALKER, 1, Point2d.of(22f, 20f), 2));
// Both execute atomically in the next onStep() — single sendDebug() call flushes both
```

The caller doesn't need to know about threading; the queue is the interface.

### Why this is non-obvious
The natural approach is to call `agent.debug().debugCreateUnit(...)` directly from wherever you need it — which throws an NPE because `debug()` is only safe in `onStep()` (see GE-0027). The queue pattern inverts this: instead of the caller pushing commands into SC2, the caller pushes commands into the agent, and the agent delivers them at the right moment. Most developers would reach for locks, synchronised blocks, or executor services — the queue as the interface is simpler.

### When to use it
- Any time you need to trigger SC2 debug API commands from a thread that isn't the game loop
- REST endpoints, test setup methods, `@Scheduled` tasks, CDI event handlers
- Batch multiple debug commands and flush once per frame for efficiency

The delay is at most one SC2 frame (~45ms at normal game speed).

*Score: 12/15 · Included because: elegant workaround to a non-obvious threading restriction; queue-as-interface pattern is reusable beyond this specific context · Reservation: none identified*

---

## ocraft `S2Coordinator` builder ends with `.launchStarcraft()` — there is no `.create()` terminal call

**ID:** GE-0026
**Stack:** ocraft-s2client-bot 0.4.21
**Symptom:** Adding `.create()` at the end of an `S2Coordinator.setup()` builder chain causes a compile error — the method does not exist. `launchStarcraft()` is both the configuration step and the terminal call that returns the `S2Coordinator` instance.
**Context:** Any code setting up an ocraft `S2Coordinator` to launch or connect to StarCraft II.

### What was tried (didn't work)
- `S2Coordinator.setup()...launchStarcraft().create()` — `create()` does not exist
- `S2Coordinator.setup()...build()` — `build()` does not exist

### Root cause
ocraft's `S2Coordinator` builder uses a fluent interface where the final platform-specific connection method (`.launchStarcraft()` or `.connectToLaunched(host, port)`) is the terminal call. It immediately begins launching the SC2 process rather than deferring to a separate build step.

### Fix

```java
// WRONG — .create() does not exist
S2Coordinator coordinator = S2Coordinator.setup()
    .loadSettings(new String[]{})
    .setParticipants(
        S2Coordinator.createParticipant(Race.PROTOSS, botAgent),
        S2Coordinator.createComputer(Race.RANDOM, Difficulty.VERY_EASY)
    )
    .launchStarcraft()
    .create(); // COMPILE ERROR

// CORRECT — launchStarcraft() is the terminal call
S2Coordinator coordinator = S2Coordinator.setup()
    .loadSettings(new String[]{})
    .setParticipants(
        S2Coordinator.createParticipant(Race.PROTOSS, botAgent),
        S2Coordinator.createComputer(Race.RANDOM, Difficulty.VERY_EASY)
    )
    .launchStarcraft(); // returns S2Coordinator directly

// Then start the game separately:
coordinator.startGame(BattlenetMap.of("Simple128"));
```

### Why this is non-obvious
The Java builder pattern convention (`setup()...build()` or `setup()...create()`) leads every developer to add a terminal call after `launchStarcraft()`. ocraft breaks this convention silently with a compile error that mentions an unknown method rather than explaining the builder design.

*Score: 10/15 · Included because: saves the "why doesn't create() exist?" lookup; convention violation is the trap · Reservation: compile-time only; quick fix once you know*

---

## ocraft `DebugInterface` has no `debugSetMinerals(int)` — precise resource setting requires raw protobuf

**ID:** GE-0028
**Stack:** ocraft-s2client-bot 0.4.21
**Symptom:** There is no `debugSetMinerals(int)` or `debugSetVespene(int)` method on ocraft's `DebugInterface`. The only resource-related debug method is `debugGiveAllResources()` which maxes out all resources. Setting specific values (e.g. exactly 500 minerals) is not possible through ocraft's high-level API.
**Context:** Any code using the SC2 debug API to set up specific economic scenarios for testing.

### What was tried (didn't work)
- `debug().debugSetMinerals(500)` — method does not exist
- `debug().debugSetVespene(200)` — method does not exist
- Searching ocraft `DebugInterface` for any "mineral" or "resource" setter — only `debugGiveAllResources()` found

### Root cause
ocraft 0.4.21 exposes a subset of SC2's debug protocol. The SC2 debug API does support `DebugSetUnitValue` with `UnitValue.MINERALS` and `UnitValue.VESPENE` at the protobuf level, but ocraft has not surfaced these as high-level Java methods.

### Fix / Workaround

**For approximate resources (against live SC2):**
```java
debug().debugGiveAllResources(); // maxes minerals + vespene + gas
debug().sendDebug();
```
Then drain by training units to reach the desired level. Impractical for precise testing.

**For exact resources in tests: use the mock instead.**
```java
simulatedGame.setMinerals(500); // SimulatedGame supports exact values
```
The stateful mock (see GE-0025) exposes `setMinerals(int)` and `setVespene(int)` directly. Design economic test scenarios against the mock, not live SC2, for precision.

### Why this is non-obvious
SC2's debug protocol clearly supports precise resource setting. ocraft exposes many debug capabilities but silently omits this one. The method name you'd expect (`debugSetMinerals`) follows the pattern of every other ocraft debug method but simply doesn't exist.

*Score: 12/15 · Included because: expected API that follows ocraft naming conventions — silently absent · Reservation: workaround exists; impact is test precision, not correctness*

---

## ocraft unit observation returns `UnitInPool` wrapper with Optional fields — not plain `Unit` objects

**ID:** GE-0029
**Stack:** ocraft-s2client-bot 0.4.21
**Symptom:** Code that calls `obs.getUnits()` and iterates expecting `Unit` objects fails to compile — the returned type is `List<UnitInPool>`. Further surprises: `unit.getType()` returns a `UnitType` interface (not the `Units` enum), `unit.getHealth()` and `getHealthMax()` return `Optional<Float>` (not plain float), and `unit.getTag()` returns a `Tag` object (not a long).
**Context:** Any code reading SC2 unit data from `ObservationInterface` in an `S2Agent` subclass.

### What was tried (didn't work)
- `List<Unit> units = obs.getUnits()` — type error; actual return is `List<UnitInPool>`
- `unit.getType() == Units.PROTOSS_ZEALOT` — type error; `getType()` returns `UnitType` interface not `Units` enum
- `(int) unit.getHealth()` — type error; returns `Optional<Float>` not `float`
- `unit.getTag()` as a long — type error; returns `Tag` wrapper object

### Root cause
ocraft wraps raw SC2 protobuf units in `UnitInPool` to support snapshot/change tracking across frames. The `UnitType` interface abstraction exists because the SC2 API's unit type IDs can map to multiple concrete enum types. Optional health/shield/energy reflects that units can have zero values — the API distinguishes "not present" from "zero".

### Fix

```java
// Correct iteration pattern
for (UnitInPool uip : obs.getUnits()) {
    com.github.ocraft.s2client.protocol.unit.Unit unit = uip.unit();

    // getType() returns UnitType interface — cast to Units enum for switch
    Units unitEnum = (unit.getType() instanceof Units u) ? u : Units.INVALID;

    // getTag() returns Tag — call getValue() for the long
    long tag = unit.getTag().getValue();

    // getHealth()/getHealthMax() return Optional<Float>
    int health    = (int) unit.getHealth().orElse(0f);
    int maxHealth = (int) unit.getHealthMax().orElse(0f);

    // getPosition() returns Point — use getX()/getY()
    float x = unit.getPosition().getX();
    float y = unit.getPosition().getY();

    // getAlliance() returns Alliance — compare directly
    boolean isSelf = unit.getAlliance() == Alliance.SELF;
}
```

### Why this is non-obvious
Every ocraft tutorial, README, and the Javadoc heading says "get a list of units" — nothing mentions `UnitInPool`. The Java type system fails silently until compile errors, and each error message points to a type you've never seen before. Each of the four type surprises (UnitInPool, UnitType interface, Optional fields, Tag) is discovered separately.

*Score: 14/15 · Included because: every ocraft user hits every one of these in sequence; combines four related surprises into one entry · Reservation: none identified*

---

## ocraft `Units` enum uses full underscore separation for multi-word building names

**ID:** GE-0030
**Stack:** ocraft-s2client-bot 0.4.21
**Symptom:** Code referencing `Units.PROTOSS_CYBERNETICSCORE` or `Units.PROTOSS_ROBOTICSFACILITY` does not compile — the constants use fully separated underscore names: `PROTOSS_CYBERNETICS_CORE`, `PROTOSS_ROBOTICS_FACILITY`, etc.
**Context:** Any code with switch statements or maps over Protoss building types using the ocraft `Units` enum.

### What was tried (didn't work)
- `Units.PROTOSS_CYBERNETICSCORE` — does not exist
- `Units.PROTOSS_ROBOTICSFACILITY` — does not exist
- `Units.PROTOSS_TWILIGHTCOUNCIL` — does not exist

### Root cause
ocraft follows StarCraft's in-game unit/building names using full underscore separation for every word.

### Fix

| Wrong | Correct |
|-------|---------|
| `PROTOSS_CYBERNETICSCORE` | `PROTOSS_CYBERNETICS_CORE` |
| `PROTOSS_ROBOTICSFACILITY` | `PROTOSS_ROBOTICS_FACILITY` |
| `PROTOSS_TWILIGHTCOUNCIL` | `PROTOSS_TWILIGHT_COUNCIL` |
| `PROTOSS_DARKSHRINE` | `PROTOSS_DARK_SHRINE` |
| `PROTOSS_TEMPLARARCHIVE` | `PROTOSS_TEMPLAR_ARCHIVE` |
| `PROTOSS_FLEETBEACON` | `PROTOSS_FLEET_BEACON` |
| `PROTOSS_ROBOTICSBAY` | `PROTOSS_ROBOTICS_BAY` |

Simple rule: **every word in the building name gets its own underscore segment.**

### Why this is non-obvious
Single-word buildings (`PROTOSS_NEXUS`, `PROTOSS_PYLON`, `PROTOSS_GATEWAY`) work with the intuitive camelCase-fused form, training the wrong expectation for multi-word names.

*Score: 11/15 · Included because: single-word buildings train wrong expectation; compile errors appear per-constant making it look like a version/import issue · Reservation: compile-time only; trivial once the pattern is known*
