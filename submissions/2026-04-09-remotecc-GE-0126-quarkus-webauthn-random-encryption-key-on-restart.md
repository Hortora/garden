**Type:** gotcha
**Submission ID:** GE-0126
**Date:** 2026-04-09
**Project:** remotecc
**Stack:** Quarkus 3.9.x, quarkus-security-webauthn
**Suggested target:** `quarkus/testing.md` (existing file)

---

## Quarkus WebAuthn generates a new random session encryption key on every restart — silently invalidates all auth cookies

**Symptom:** After a server restart, REST API calls from the browser return 401 silently (if errors are swallowed in `.catch()`), while an already-open WebSocket connection continues working. The UI appears functional (terminal displays content) but all authenticated HTTP requests fail. Result: features that use `fetch()` to call `/api/*` endpoints stop working with no visible error.

**Context:** Running Quarkus WebAuthn in production mode without setting `QUARKUS_HTTP_AUTH_SESSION_ENCRYPTION_KEY`. A WARN log is emitted at startup: `"Encryption key was not specified for persistent WebAuthn auth, using temporary key XYZ="`. The key is different on every restart, so session cookies encrypted with the previous key are rejected.

**What was tried:** Assumed the compose overlay's `ws.send()` was the problem (wrong). Switched to REST API fetch calls (still silent 401). Added console logging (revealed nothing because the JAR hadn't been rebuilt). Multiple failed approaches over several iterations before the WARN log was noticed.

**Root cause:** Quarkus uses the encryption key to sign session cookies. Without a stable key, every restart invalidates all existing cookies. The WebSocket is unaffected because it authenticates at connection time via the cookie and then keeps the TCP connection alive — new cookies are only checked on new connections.

**Fix:** Set `QUARKUS_HTTP_AUTH_SESSION_ENCRYPTION_KEY=<secret-32-chars>` as an environment variable when starting the server. For local dev, add it to `application.properties` as `%prod.quarkus.http.auth.session.encryption-key=...`.

**Why non-obvious:** The WARN log is easy to miss. The symptom (REST 401, WebSocket alive) looks like a CORS or session issue, not a key rotation issue. The divergence between WebSocket (still auth'd) and REST (auth expired) is particularly confusing — it implies the user is logged in (terminal works) but somehow not logged in (API fails).

*Score: 13/15 · Included because: high pain (caused multiple debugging sessions), the WebSocket-alive / REST-dead symptom actively misleads, the fix is a single env var but finding the cause is hard · Reservation: none*
