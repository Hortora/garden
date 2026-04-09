**Submission ID:** GE-0151
**Date:** 2026-04-09
**Project:** quarkmind
**Type:** technique
**Stack:** Java 11 WebSocket, Quarkus 3.34.2 (quarkus-websockets-next), JUnit 5, Playwright Java
**Labels:** #testing #strategy

## Prove WebSocket end-to-end connectivity by waiting for first message, not just `onOpen`

**Technique:** When testing a WebSocket server-push chain in a `@QuarkusTest`, wait for the first actual message to arrive in the browser before making test assertions — not just for `ws.onopen` or the server's `@OnOpen` callback. This eliminates a race condition that causes tests to fail intermittently.

**The race:** `ws.onopen` fires in the browser after the TCP handshake, but before the server's `@OnOpen` handler has finished executing `addSession(connection)`. If you trigger `engine.observe()` (which broadcasts to registered sessions) immediately after `ws.onopen`, the session may not yet be in the broadcaster's session set — the message is sent to zero clients.

**What developers normally do:** Wait for `ws.onopen`, assume the server session is registered, then trigger the operation that causes the server to push a message. This is a race that fails maybe 10–20% of runs depending on server load.

**The approach:**

```javascript
// In the app JS — expose connection state
let wsConnected = false;
function connect() {
    const ws = new WebSocket(...);
    ws.onopen  = () => { wsConnected = true; };
    ws.onclose = () => { wsConnected = false; ... };
    ...
}
window.__test = { wsConnected: () => wsConnected, ... };
```

```java
// In the test — open page, prove E2E connectivity via first message
private Page openPage() {
    Page page = browser.newPage();
    page.navigate(pageUrl.toString());
    
    // 1. Wait for JS init + WebSocket handshake (browser side)
    page.waitForFunction("() => window.__test && window.__test.wsConnected()",
        null, new Page.WaitForFunctionOptions().setTimeout(10_000));
    
    // 2. Fire a server push and wait for the message to arrive in the browser.
    //    This proves the server's @OnOpen handler has registered the session.
    engine.observe();
    page.waitForFunction("() => window.__test.hudText() !== 'Connecting...'",
        null, new Page.WaitForFunctionOptions().setTimeout(5_000));
    
    return page; // guaranteed end-to-end ready
}
```

**Why non-obvious:** The `ws.onopen` / server `@OnOpen` ordering is not documented as a potential race. It only manifests in `@QuarkusTest` where the server handler runs on a reactive executor with possible scheduling delay. Using `waitForFunction` with a functional condition (not a timeout) makes the test reliable on any machine speed.

**Suggested target:** `tools/playwright.md`

*Score: 12/15 · Included because: eliminates a common flaky test pattern, requires knowing that @OnOpen is not synchronous with browser onopen, waitForFunction-on-first-message is a non-obvious pattern · Reservation: Quarkus-specific trigger, but pattern is general*
