**Type:** gotcha
**Submission ID:** GE-0094
**Date:** 2026-04-08
**Project:** remotecc
**Stack:** Quarkus 3.9.x, quarkus-junit5, @QuarkusTest
**Suggested target:** `quarkus/testing.md` (new file — `# Quarkus Gotchas and Techniques`)

---

## @QuarkusTest HTTP endpoint tests fire real @ApplicationScoped beans — including side-effectful adapters

**Symptom:** Running `mvn test` opens real iTerm2 terminal windows (or triggers other real external side effects) with no warning in test output. The test passes or fails normally; the side effect is only visible because windows appear on screen or external systems are mutated.

**Context:** A `@QuarkusTest` class makes HTTP calls to an endpoint (`POST /api/sessions/{id}/open-terminal`). The endpoint injects an `@ApplicationScoped` adapter (`TerminalAdapterFactory`) that is *not* mocked. The adapter's `openSession()` calls AppleScript to open an iTerm2 window.

**What was tried:** Added the test to the existing `SessionResourceTest` class (which makes real HTTP calls to real endpoints). Expected test isolation to prevent external side effects.

**Root cause:** `@QuarkusTest` starts a real Quarkus CDI container. All `@ApplicationScoped` beans are fully instantiated and their real methods are called. There is no automatic sandbox or stub layer — if a bean opens a window, sends an email, or writes to a file, it does so during the test. The HTTP test layer is not a unit test; it exercises the real application stack end to end.

**Fix:** Use `@InjectMock` on the side-effectful bean in a dedicated test class (see GE-0095). In the test class with `@InjectMock TerminalAdapterFactory`, Mockito intercepts all calls and no real AppleScript is executed.

**Why non-obvious:** `@QuarkusTest` looks like a test framework with test isolation. The name and the `@Test` annotation imply safety. Nothing in the test output, the Quarkus docs overview, or the test setup signals that `@ApplicationScoped` beans will execute their real production logic including external system calls.

*Score: 14/15 · Included because: high pain (real windows opened on every test run), high breadth (any Quarkus app with side-effectful CDI beans), not obvious from the framework name or docs · Reservation: none*
