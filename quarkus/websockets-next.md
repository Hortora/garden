# Quarkus WebSockets Next Gotchas

---

## Quarkus WebSockets Next @OnOpen silently stops firing after hot-reload

**ID:** GE-20260412-59ef31
**Stack:** Quarkus 3.9.5, quarkus-websockets-next
**Symptom:** After a hot-reload in dev mode, WebSocket HTTP 101 upgrade succeeds (handshake OK) but `@OnOpen` is never called. No log entries from WebSocket handlers appear. REST endpoints continue working normally. No error message anywhere.
**Context:** Dev mode only. Triggered by any Java change that causes a Quarkus hot-reload. WebSocket connections made before the hot-reload continue working; new connections after are silently dead.

### What was tried (didn't work)
- Verified WebSocket URL is correct — upgrade still returns 101, so the path is fine
- Confirmed `@WebSocket` annotation and path are present and correct
- Reconnected multiple times from different clients — all silently dead
- Checked Vert.x route registration logs — no error, routes appear registered

### Root cause
Quarkus WebSockets Next re-registers WebSocket endpoint handlers at application startup. In dev mode, hot-reload restarts the application layer but does not correctly re-wire the WebSocket handler at the Vert.x routing level. Vert.x handles the HTTP upgrade directly (so the 101 handshake succeeds — Vert.x's own upgrade logic is intact), but the application-level `@OnOpen` / `@OnTextMessage` / `@OnClose` handlers are no longer wired into the route chain. The connection is accepted at the transport layer but orphaned at the application layer.

### Fix
Full server process restart is required — there is no way to recover a dead WebSocket endpoint after hot-reload without it:

```bash
pkill -f "quarkus:dev"
sleep 2
JAVA_HOME=$(/usr/libexec/java_home -v 26) mvn quarkus:dev -Dremotecc.mode=server
```

**Rule:** After any Java commit that triggers hot-reload during an active dev session, always do a full restart before testing WebSocket behaviour. Hot-reload is reliable for REST endpoints but not for WebSockets Next.

### Why this is non-obvious
The HTTP 101 response is completely convincing — the WebSocket handshake genuinely succeeds at the transport level. Vert.x correctly handles the upgrade. All REST endpoints continue working normally. The symptom looks exactly like a WebSocket client bug or a wrong session ID. There is no error in the server log — it is a silent loss of handler wiring. A developer would spend significant time debugging the client before suspecting the server-side handler registration.
