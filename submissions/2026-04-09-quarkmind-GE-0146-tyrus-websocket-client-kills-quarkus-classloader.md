**Submission ID:** GE-0146
**Date:** 2026-04-09
**Project:** quarkmind
**Type:** gotcha
**Stack:** Quarkus 3.34.2, tyrus-standalone-client 2.1.5, JUnit 5

## Tyrus WebSocket client causes `ArC container not initialized` in @QuarkusTest

**Symptom:** `java.lang.IllegalStateException: ArC container not initialized: the container is not started, already shut down, or a wrong class loader was used to load the io.quarkus.arc.Arc class` when running a `@QuarkusTest`. Tests that previously passed now fail during the WebSocket client `connectToServer()` call.

**Context:** Occurs when `tyrus-standalone-client` (Jakarta WS reference implementation) is added to the project's test dependencies and used inside a `@QuarkusTest` to connect to a WebSocket endpoint.

**What was tried:** Adding `tyrus-standalone-client:2.1.5` to pom.xml test scope and using `ContainerProvider.getWebSocketContainer().connectToServer(...)`.

**Root cause:** Tyrus uses `ServiceLoader` to find the `ContainerProvider` implementation. In a Quarkus test, the application classloader and the test classloader are separate. Tyrus's `ServiceLoader` invocation uses the wrong classloader, causing it to bootstrap a second CDI container that conflicts with Quarkus's existing container.

**Fix:** Use Java 11's built-in `java.net.http.WebSocket` — no external dependency, no classloader conflict:

```java
// WRONG — tyrus conflicts with Quarkus classloader
Session session = ContainerProvider.getWebSocketContainer()
    .connectToServer(endpoint, wsUri);

// FIX — Java 11 built-in, no dependency needed
WebSocket ws = HttpClient.newHttpClient()
    .newWebSocketBuilder()
    .buildAsync(wsUri, listener)
    .join();
ws.request(1);
```

**Why non-obvious:** Tyrus works fine in standard Java apps and in Quarkus apps outside of `@QuarkusTest`. The classloader isolation only applies in the test harness. The error message says "container not initialized" — looks like a Quarkus startup problem, not a classloader problem.

**Suggested target:** `quarkus/testing.md`

*Score: 13/15 · Included because: completely misleading error message, affects anyone adding WS client tests to Quarkus, easy to waste hours debugging Quarkus startup · Reservation: none*
