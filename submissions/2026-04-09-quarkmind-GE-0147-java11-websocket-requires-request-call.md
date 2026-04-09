**Submission ID:** GE-0147
**Date:** 2026-04-09
**Project:** quarkmind
**Type:** undocumented
**Stack:** Java 11+ (java.net.http.WebSocket)

## Java 11 WebSocket: `ws.request(N)` must be called before `onText` fires

**Symptom:** WebSocket connects successfully (no error), server sends messages (confirmed via server logs), but the `onText` callback in the `WebSocket.Listener` never fires. Messages are silently dropped.

**Context:** Occurs after `HttpClient.newHttpClient().newWebSocketBuilder().buildAsync(uri, listener).join()`. The connection is open, the server broadcasts, but the listener receives nothing.

**What was tried:** Verified server was sending messages. Verified WebSocket URL was correct. Verified listener was registered. `ws.isInputClosed()` returned false.

**Root cause:** `java.net.http.WebSocket` uses demand-based flow control. After connecting, the default message demand is zero. The listener's `onText` method will never be called until the consumer explicitly requests messages by calling `ws.request(N)`.

**Fix:**

```java
WebSocket ws = HttpClient.newHttpClient()
    .newWebSocketBuilder()
    .buildAsync(uri, new WebSocket.Listener() {
        @Override
        public CompletionStage<?> onText(WebSocket ws, CharSequence data, boolean last) {
            // process message
            ws.request(1); // ← request the next message
            return null;
        }
    })
    .join();

ws.request(1); // ← REQUIRED: request the first message after connect
```

**Why undocumented:** The demand model is mentioned in the Javadoc for `WebSocket.Listener` but is easy to miss — the class-level description focuses on the callback methods. There are no examples in the official Java docs or tutorials that show `ws.request(1)` being called after `buildAsync`. Most HTTP examples don't involve this API.

**Suggested target:** `tools/java-http-client.md` (new file: `# Java HTTP Client Gotchas and Techniques`)

*Score: 12/15 · Included because: completely silent failure, easy to spend hours debugging "server not sending", nothing in typical examples shows this requirement · Reservation: Javadoc does mention it, though buried*
