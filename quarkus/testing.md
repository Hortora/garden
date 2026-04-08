# Quarkus Testing Gotchas

---

## @ApplicationScoped bean state accumulates across @QuarkusTest classes in the same run

**ID:** GE-0036
**Stack:** Quarkus 3.9.x, JUnit 5
**Symptom:** Tests in class B fail with unexpected status codes (e.g. 429 instead of 403) even though class B's own setup looks correct. No stack trace — just the wrong response. Class A, which ran earlier, behaved correctly in isolation.
**Context:** Any `@QuarkusTest` suite where an `@ApplicationScoped` bean holds mutable state (counters, caches, rate-limiter windows, session maps). All `@QuarkusTest` classes share a single application instance for the entire test run.

### What was tried (didn't work)
- Checked class B's `@BeforeEach` — it reset the bean's state correctly before each test *in class B*
- Verified class B's tests pass in isolation (`mvn test -Dtest=ClassB`)
- Reread class B's test logic — all assertions look correct given the setup

### Root cause

Quarkus starts **one application instance** for the entire test run and reuses it across all `@QuarkusTest` classes. `@ApplicationScoped` beans are singletons within that instance. Mutable state written by class A persists into class B's test execution.

A concrete example: `AuthRateLimiterHttpTest` exhausted a rate limiter's 10-request window for `127.0.0.1`. `AuthResourceTest` ran next, hit the same endpoint from `127.0.0.1`, and received 429 instead of the expected 403. The symptom gave no indication the cause was in a different test class.

### Fix

Add `@AfterEach` cleanup in any test class that exercises a stateful `@ApplicationScoped` bean, alongside the `@BeforeEach` that already resets before each test *within* the class:

```java
@Inject
AuthRateLimiter rateLimiter;   // the stateful @ApplicationScoped bean

@BeforeEach
void setUp() {
    rateLimiter.resetForTest(); // clean before each test in this class
}

@AfterEach
void tearDown() {
    // clean after each test so state doesn't bleed into subsequent test classes
    // (all @QuarkusTest classes share one app instance and one bean instance)
    rateLimiter.resetForTest();
}
```

The bean needs a package-private reset method (avoid making it public — it's test infrastructure):

```java
// In the @ApplicationScoped bean:
void resetForTest() {
    attempts.clear();
}
```

### Why this is non-obvious

The failure symptom is in class B with no connection to class A — class B's own setup is correct, and class A's tests all passed. Nothing in the error output points to cross-class state. Reproduces only when both classes run together (`mvn test`), not individually. The cause (shared app instance) is mentioned in Quarkus docs but easy to miss when writing the first test class that exercises a stateful bean.

*Score: 15/15 · Included because: perfect non-obvious cause, invisible from error output, affects any stateful bean in any Quarkus project, passes in isolation · Reservation: none identified*

---

## @QuarkusTest HTTP endpoint tests fire real @ApplicationScoped beans — including side-effectful adapters

**ID:** GE-0094
**Stack:** Quarkus 3.9.x, quarkus-junit5, @QuarkusTest
**Symptom:** Running `mvn test` opens real iTerm2 terminal windows (or triggers other real external side effects) with no warning in test output. The test passes or fails normally; the side effect is only visible because windows appear on screen or external systems are mutated.
**Context:** A `@QuarkusTest` class makes HTTP calls to an endpoint. The endpoint injects an `@ApplicationScoped` adapter that is not mocked. The adapter's method calls AppleScript to open an iTerm2 window.

### Root cause
`@QuarkusTest` starts a real Quarkus CDI container. All `@ApplicationScoped` beans are fully instantiated and their real methods are called. There is no automatic sandbox or stub layer — if a bean opens a window, sends an email, or writes to a file, it does so during the test.

### Fix
Use `@InjectMock` on the side-effectful bean in a dedicated test class. See GE-0095 for the full technique.

### Why non-obvious
`@QuarkusTest` looks like a test framework with test isolation. The name and the `@Test` annotation imply safety. Nothing in the test output or Quarkus docs overview signals that `@ApplicationScoped` beans will execute their real production logic including external system calls.

**See also:** GE-0095 (dedicated @QuarkusTest class with @InjectMock), GE-0036 (@ApplicationScoped state accumulates across @QuarkusTest classes)

*Score: 14/15 · Included because: high pain (real windows opened on every test run), high breadth, not obvious from the framework name or docs · Reservation: none*

---

## Use a dedicated @QuarkusTest class with @InjectMock to isolate side-effectful endpoint tests

**ID:** GE-0095
**Stack:** Quarkus 3.9.x, quarkus-junit5, @QuarkusTest, @InjectMock, Mockito
**Labels:** `#testing` `#pattern`
**What it achieves:** Prevents real side effects from firing during HTTP-level endpoint tests, while keeping the main integration test class free from mock contamination that would affect unrelated tests.
**Context:** `@InjectMock` on a bean replaces it with a Mockito mock for the *entire test class*. Adding it to an existing integration test class forces mock setup for every test in that class — including tests that should exercise the real bean (see GE-0094).

### The technique

Create a separate `@QuarkusTest` class dedicated to the endpoint that needs mocking:

```java
@QuarkusTest
@TestSecurity(user = "test", roles = "user")
class OpenTerminalTest {

    @InjectMock
    TerminalAdapterFactory terminalFactory;   // mocked for this whole class

    @Inject SessionRegistry registry;

    @BeforeEach
    void resetMock() {
        Mockito.reset(terminalFactory);
        Mockito.when(terminalFactory.resolve()).thenReturn(Optional.empty());
    }

    @AfterEach
    void cleanup() throws Exception {
        for (var s : registry.all()) {
            registry.remove(s.id());
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
}
```

### Why this is non-obvious
The natural instinct is to add the test to the existing test class alongside other endpoint tests. `@InjectMock` looks like it should be test-scoped, but it's class-scoped — mixing mocked and unmocked tests for the same bean in one class silently changes behaviour for all tests. The "dedicated class" solution isn't mentioned in Quarkus testing docs.

**See also:** GE-0094 (the gotcha this technique resolves)

*Score: 12/15 · Included because: high breadth, elegant solution, non-obvious class-scope implication · Reservation: @InjectMock itself is documented; the pattern is the insight*
