**Type:** technique
**Submission ID:** GE-0095
**Date:** 2026-04-08
**Project:** remotecc
**Stack:** Quarkus 3.9.x, quarkus-junit5, @QuarkusTest, @InjectMock, Mockito
**Labels:** #testing, #pattern
**Suggested target:** `quarkus/testing.md` (new file — `# Quarkus Gotchas and Techniques`)
**Related:** GE-0094 (the gotcha this technique resolves)

---

## Use a dedicated @QuarkusTest class with @InjectMock to isolate side-effectful endpoint tests

**What it achieves:** Prevents real side effects (iTerm2 windows, database writes, external API calls) from firing during HTTP-level endpoint tests, while keeping the main integration test class free from mock contamination that would affect unrelated tests.

**The problem:** `@InjectMock` on a bean replaces it with a Mockito mock for the *entire test class*. Adding it to an existing integration test class (e.g. `SessionResourceTest`) forces mock setup for every test in that class — including tests that should exercise the real bean. This breaks isolation in the other direction.

**The technique:** Create a separate `@QuarkusTest` class dedicated to the endpoint that needs mocking:

```java
@QuarkusTest
@TestSecurity(user = "test", roles = "user")
class OpenTerminalTest {

    @InjectMock
    TerminalAdapterFactory terminalFactory;   // mocked for this whole class

    @Inject SessionRegistry registry;
    @Inject TmuxService tmux;

    @BeforeEach
    void resetMock() {
        Mockito.reset(terminalFactory);
        Mockito.when(terminalFactory.resolve()).thenReturn(Optional.empty());
    }

    @AfterEach
    void cleanup() throws Exception {
        for (var s : registry.all()) {
            registry.remove(s.id());
            try { tmux.killSession(s.name()); } catch (Exception ignored) {}
        }
    }

    @Test
    void openTerminalReturns200WhenAdapterAvailable() throws Exception {
        var adapter = Mockito.mock(TerminalAdapter.class);
        Mockito.when(adapter.name()).thenReturn("iterm2");
        Mockito.doNothing().when(adapter).openSession(Mockito.anyString());
        Mockito.when(terminalFactory.resolve()).thenReturn(Optional.of(adapter));
        // ... test the happy path without opening real windows
        Mockito.verify(adapter).openSession(Mockito.contains("session-name"));
    }

    @Test
    void openTerminalReturns503WhenNoAdapterAvailable() {
        // resolve() returns empty by default from @BeforeEach
        // ... test the no-adapter path
    }
}
```

The existing `SessionResourceTest` remains unmocked and exercises the real adapter (or none, in CI). The dedicated class handles all mock-dependent tests cleanly.

**Why non-obvious:** The natural instinct is to add the test to the existing test class alongside other endpoint tests. `@InjectMock` *looks* like it should be test-scoped, but it's class-scoped — mixing mocked and unmocked tests for the same bean in one class silently changes behavior for all tests. The "dedicated class" solution isn't mentioned in Quarkus testing docs; it has to be derived from understanding how `@InjectMock` scope works.

*Score: 12/15 · Included because: high breadth (any Quarkus app with side-effectful CDI beans), elegant solution, non-obvious class-scope implication · Reservation: @InjectMock itself is documented; the pattern is the insight*
