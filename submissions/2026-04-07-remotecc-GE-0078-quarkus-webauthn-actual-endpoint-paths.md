**Submission ID:** GE-0078
**Date:** 2026-04-07
**Project:** remotecc
**Type:** undocumented
**Suggested target:** `quarkus/quarkus-webauthn.md` (new file — header: `# Quarkus WebAuthn Gotchas and Techniques`)

## Quarkus WebAuthn Actual HTTP Endpoint Paths (Only Discoverable via Bytecode)

**Stack:** Quarkus 3.9.x (`quarkus-security-webauthn`), Vert.x 4.5.x

**What exists:** The Quarkus WebAuthn extension registers four HTTP endpoints under the non-application root (`/q/`):

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/q/webauthn/register` | POST | Step 1: server returns WebAuthn challenge options |
| `/q/webauthn/login` | POST | Step 1: server returns WebAuthn login challenge |
| `/q/webauthn/callback` | POST | Step 2: client submits credential/assertion |
| `/q/webauthn/webauthn.js` | GET | Quarkus-provided JS helper library |

**Why it's undocumented:** The Quarkus WebAuthn guide does not list these paths explicitly. The recommended usage is to use the provided `webauthn.js` client library which calls them internally. The paths appear only as string constants in `WebAuthnRecorder.class` — discoverable via:
```bash
javap -verbose WebAuthnRecorder.class | grep "webauthn/"
# → #151 = String "webauthn/login"
# → #168 = String "webauthn/register"
# → #174 = String "webauthn/callback"
# → #180 = String "webauthn/webauthn.js"
```

**Common mistake:** Most WebAuthn tutorials describe a two-step REST pattern with `/options` and `/finish` endpoints. Quarkus uses a single-step per phase: `POST /q/webauthn/register` returns the challenge AND triggers the browser ceremony (via the JS library), then `POST /q/webauthn/callback` receives the result. There are no `/options` or `/finish` endpoints.

**Verification:**
```bash
# Returns 200 (JS helper served)
curl http://localhost:7777/q/webauthn/webauthn.js

# Returns 400 if body missing 'name' field (route exists)
curl -X POST http://localhost:7777/q/webauthn/register \
  -H 'Content-Type: application/json' -d '{}'

# Returns 404 (these don't exist in Quarkus WebAuthn)
curl -X POST http://localhost:7777/q/webauthn/register/options
curl -X POST http://localhost:7777/q/webauthn/register/finish
```

*Score: 13/15 · Included because: genuinely absent from official docs, only findable via bytecode inspection, common wrong assumption causes hours of debugging · Reservation: Quarkus-version-specific*
