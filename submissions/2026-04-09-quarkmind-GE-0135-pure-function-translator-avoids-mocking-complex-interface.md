**Submission ID:** GE-0135
**Date:** 2026-04-09
**Type:** technique
**Project:** quarkmind (cross-project — any Java project with complex interfaces)
**Labels:** #testing #pattern

## Return resolved data instead of calling a complex interface directly — eliminates mocking even with 12+ overloads

### The technique

When implementing a translator that ultimately calls a complex interface
(e.g. one with 12+ overloads), make the translator return a plain data list
instead of calling the interface directly. The caller applies the data to the
interface. The translator becomes a pure function — testable with plain
AssertJ, no mocking framework needed.

**Without this pattern:** translator calls `ActionInterface.unitCommand(...)` inside
→ to test it, you must mock `ActionInterface` (12+ overloads to stub).

**With this pattern:**

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

The instinct when translating to a target system is to call that system
directly — "translate and dispatch". The insight is that translation (producing
`ResolvedCommand` records) and dispatch (calling `ActionInterface`) are separable
concerns. Splitting them at a data boundary makes the translation logic a pure
function that a test can exercise without the target system being present.

Most developers would reach for Mockito to mock the interface. With a complex
interface (ocraft `ActionInterface` has 12+ `unitCommand` overloads), the mock
setup is verbose and brittle. Returning data instead eliminates the need for
any mocking framework.

### When to use it

- The target interface has many overloads or is difficult to mock
- The "translate" logic is worth testing independently from dispatch
- A mocking framework is not yet in the project and adding one feels heavy
- The translator is a pure mapping (no side effects), which is verifiable by
  inspecting the returned data

### Stack

Java 21+, but applicable in any language with records/value objects

*Score: 11/15 · Included because: the specific pattern of returning data to avoid mocking is non-obvious; most developers reach for Mockito reflexively · Reservation: experienced TDD practitioners may know this as "humble object" or "ports and adapters"*
