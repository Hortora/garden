# Testing Patterns — Gotchas and Techniques

Non-obvious patterns for testing systems with external dependencies or mocks.

---

## Use a stateful mock as a living specification that accumulates knowledge of the real system

**ID:** GE-0025
**Stack:** Any language / framework where the real dependency is hard to test against (game engines, hardware APIs, paid third-party services, licensed software)
**Labels:** `#testing` `#strategy`
**What it achieves:** Enables fast, deterministic, offline tests against a realistic simulation of an external system. The mock grows more faithful over time as real-system surprises are codified as mock rules and regression tests.
**Context:** When the real external system is unavailable in CI, expensive to connect to, non-deterministic, or requires manual setup (e.g. StarCraft II game client, AWS services, hardware devices).

### The technique

Build the mock as a **stateful simulation** that receives commands and mutates its own state — not a simple stub that returns canned responses.

Structure:
1. **State class** (`SimulatedGame`) — mutable internal state matching the real system's key concepts. Thread-safe.
2. **Observer** — reads from the state class and produces the same output type as the real observer.
3. **Dispatcher** — receives commands/intents, applies them to the state class.
4. **Scenario library** — named mutations that trigger specific situations: `spawn-enemy-attack`, `set-resources-500`, `supply-almost-capped`. Each scenario is a function that mutates the state class.

The critical discipline: **when the real system surprises you, update the mock to replicate the quirk, then write a test for it.**

```java
// Scenario library example
@FunctionalInterface
public interface Scenario {
    void apply(SimulatedGame game);
}

public class ScenarioLibrary {
    private final Map<String, Scenario> scenarios = Map.of(
        "spawn-enemy-attack",   game -> { game.spawnEnemyUnit(ZEALOT, pos(20,20)); /* ... */ },
        "supply-almost-capped", game -> game.setSupplyUsed(game.snapshot().supply() - 1),
        "set-resources-500",    game -> { game.setMinerals(500); game.setVespene(200); }
    );
}
```

### Why this is non-obvious
Most developers use one of two strategies: simple stubs (fixed return values) or skip testing against hard dependencies entirely. The stateful mock that evolves with the real system is a third path — more investment up front, but it pays back every time the real system misbehaves and you add a test rather than just fixing the code. The living-specification discipline (update-mock-on-surprise) is the non-obvious part; most teams let the mock diverge from reality over time.

### When to use it
- The real external system is unavailable in fast-feedback CI
- The real system is non-deterministic or stateful across calls
- You need to trigger specific edge-case states hard to reproduce in the real system

Does **not** replace integration tests against the real system — mock and real integration tests are complementary.

**See also:** GE-0022 for the dual-runner pattern that enforces parity between mock and real.

*Score: 13/15 · Included because: the living-specification evolution discipline is genuinely non-obvious; most teams pick "stub or skip" · Reservation: none identified*

---

## Dual-runner scenario library: same named tests run against mock and real system

**ID:** GE-0022
**Stack:** Any language / framework with a mock mode and a real system debug/sandbox API
**Labels:** `#testing` `#strategy`
**What it achieves:** Prevents mock/real drift by ensuring the same named test scenarios run against both implementations. When a scenario produces different outcomes in mock vs real, the divergence surfaces immediately rather than silently.
**Context:** Systems where you maintain a stateful mock for fast CI testing alongside access to a real backend with a debug/sandbox API (game engines with debug commands, payment sandboxes, messaging simulators).

### The technique

Define scenarios as a shared interface and implement it twice:

```java
// The shared scenario interface
public interface ScenarioRunner {
    void run(String scenarioName);
    Set<String> availableScenarios();
}

// Implementation 1: mutates the in-process mock
@ApplicationScoped
public class MockScenarioRunner implements ScenarioRunner {
    @Override
    public void run(String scenarioName) {
        library.get(scenarioName).apply(game);  // mutates SimulatedGame directly
    }
}

// Implementation 2: calls the real system's debug API
@ApplicationScoped
@IfBuildProfile("sc2")
public class RealDebugScenarioRunner implements ScenarioRunner {
    @Override
    public void run(String scenarioName) {
        switch (scenarioName) {
            case "spawn-enemy-attack" -> debug.spawnUnits(ZEALOT, 2, pos(20,20));
            case "set-resources-500"  -> debug.setMinerals(500);
            // same names, real system debug commands
        }
    }
}
```

Scenario names are the shared contract. Tests are written against `ScenarioRunner` — they run against the mock in fast CI and against the real system in integration tests, using the same test code:

```java
@Inject ScenarioRunner scenarioRunner;

@Test
void spawnEnemyAttackChangesGameState() {
    scenarioRunner.run("spawn-enemy-attack");
    assertThat(gameObserver.observe().enemyUnits()).isNotEmpty();
}
```

### Why this is non-obvious
Most teams treat mock tests and integration tests as completely separate code, written differently, with different names. The insight is that the scenario *names* are the stable interface — the execution mechanism (mock state mutation vs real debug API call) is the variable. By sharing names and test code, you get automatic parity verification: if mock and real diverge, the same test fails in one context but not the other.

### When to use it
- Real system has a debug/sandbox/test mode that can be scripted
- Mock is stateful (not a simple stub)
- CI speed matters (mock runs fast) but correctness against real system also matters

Requires discipline to keep scenario names stable — treat them as a public API.

*Score: 12/15 · Included because: shared-name contract between mock and real is the non-obvious insight; most teams let mock and integration tests drift silently for months · Reservation: requires the real system to have a debug/sandbox API*

---

## Use `waitpid(WNOHANG)` polling to verify signal delivery in subprocess tests

**ID:** GE-0040
**Stack:** Java, POSIX, Panama FFM (or any language with waitpid access)
**Labels:** `#testing` `#pattern`
**What it achieves:** Reliably verifies that a signal was actually delivered to and processed by a subprocess — without depending on capturing output from a PTY or pipe.
**Context:** Testing that `kill(pid, SIGINT)` actually delivers SIGINT to a subprocess. Output-capture approaches (trap in shell, Python signal handler printing a marker) fail due to PTY encoding issues, shell-in-script-mode signal handling quirks, and subprocess startup timing races.

### The technique

Instead of trying to observe the subprocess's output, verify it exited:

```java
// Spawn a long-running process
pty.spawn(new String[]{"/bin/sleep", "30"});
int pid = pty.getPid();

Thread.sleep(50); // let process start
pty.sendSigInt(); // send the signal

// Poll waitpid(WNOHANG) until exit or timeout
long deadline = System.currentTimeMillis() + 2_000;
boolean exited = false;
while (System.currentTimeMillis() < deadline) {
    int ret = PosixLibrary.waitpid(pid, MemorySegment.NULL, PosixLibrary.WNOHANG);
    if (ret == pid) { exited = true; break; }
    Thread.sleep(30);
}
assertTrue(exited, "Process should have exited after SIGINT");
```

`waitpid(pid, NULL, WNOHANG)` returns:
- `pid` — process exited (reap it)
- `0` — process still running
- `-1` — error (ECHILD if already reaped)

If the signal was never delivered, the process keeps sleeping and `waitpid` returns `0` until the deadline — the test fails correctly.

### Why this is non-obvious

Most developers would try to capture subprocess output — spawn a shell with a `trap`, a Python script with a signal handler, etc. These all have failure modes:
- Shell `trap` in script mode: POSIX shells may not handle SIGINT during `sleep` consistently
- PTY output capture: encoding, line-discipline processing, and timing races make it unreliable
- Python signal handler: startup time may exceed the setup sleep; handler not yet installed when signal arrives

`waitpid(WNOHANG)` sidesteps all of this. The signal either killed the process or it didn't — the OS knows, and `waitpid` tells you exactly.

### When to use it
Any time you need to test that a signal was sent to a subprocess. Works regardless of:
- Whether the subprocess has a PTY, pipe, or /dev/null for stdio
- What language or shell the subprocess is written in
- How the subprocess handles the signal (exit or catch-and-exit)

**Caveat:** Requires access to `waitpid` (POSIX). Works cleanly when the subprocess is spawned via `posix_spawn` and the parent holds the pid.

*Score: 11/15 · Included because: output-capture approaches fail in non-obvious ways; this technique cuts through all of them cleanly · Reservation: general POSIX knowledge; skilled developers may know waitpid already*

---

## Return resolved data instead of calling a complex interface directly — eliminates mocking even with 12+ overloads

**ID:** GE-0135
**Stack:** Java 21+ (pattern is language-agnostic)
**Labels:** `#testing` `#pattern`
**What it achieves:** Makes a translator pure-function testable with plain assertions and no mocking framework, even when the target interface has many overloads.
**Context:** Implementing a translator that calls a complex interface (e.g. one with 12+ overloads). The natural approach requires mocking; this pattern eliminates the need.

### The technique
Make the translator return a plain data list instead of calling the interface directly. The caller applies the data to the interface. The translator becomes a pure function:

```java
// Translator: pure function, returns data
public static List<ResolvedCommand> translate(List<Intent> intents) { ... }

record ResolvedCommand(Tag tag, Abilities ability, Optional<Point2d> target) {}

// Caller: applies data to the interface
ActionTranslator.translate(intents).forEach(cmd ->
    cmd.target().ifPresentOrElse(
        pos -> actions().unitCommand(cmd.tag(), cmd.ability(), pos, false),
        ()  -> actions().unitCommand(cmd.tag(), cmd.ability(), false)
    )
);

// Test: pure assertions, no mocking
@Test
void buildIntentProducesCorrectCommand() {
    var intent = new BuildIntent("456", BuildingType.GATEWAY, new Point2d(30f, 40f));
    var commands = ActionTranslator.translate(List.of(intent));
    assertThat(commands.get(0).ability()).isEqualTo(Abilities.BUILD_GATEWAY);
    assertThat(commands.get(0).target()).contains(Point2d.of(30f, 40f));
}
```

### Why this is non-obvious
The instinct when translating to a target system is to call that system directly. The insight is that translation (producing `ResolvedCommand` records) and dispatch (calling `ActionInterface`) are separable concerns at a data boundary. Splitting them makes the translation logic a pure function. Most developers would reach for Mockito to mock a complex interface; with 12+ overloads, that mock setup is verbose and brittle.

### When to use it
- The target interface has many overloads or is difficult to mock
- The "translate" logic is worth testing independently from dispatch
- A mocking framework is not yet in the project
- The translator is a pure mapping (no side effects)

*Score: 11/15 · Included because: returning data to avoid mocking is non-obvious; most developers reach for Mockito reflexively · Reservation: experienced TDD practitioners may know this as "humble object" or "ports and adapters"*
