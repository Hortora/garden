# Quarkus WebAuthn Gotchas

---

## Authenticator.publicKeyAlgorithm has no getter/setter — field cannot be persisted in WebAuthnUserProvider

**ID:** GE-0104
**Stack:** Quarkus 3.9.x, quarkus-security-webauthn, io.vertx.ext.auth.webauthn.Authenticator
**Symptom:** A `WebAuthnUserProvider` implementation that stores `publicKeyAlgorithm` (e.g. `-7` for ES256) in a credential JSON file successfully writes the value, but has no way to restore it to the `Authenticator` object on lookup. No error is thrown — the field is silently unrestorable.
**Context:** Any `WebAuthnUserProvider` that tries to persist the full credential including algorithm, so the stored record accurately represents what was registered.

### What was tried (didn't work)
- Stored `publicKeyAlgorithm: -7` in the credential JSON — write succeeds, field persists to disk
- Tried `authenticator.setPublicKeyAlgorithm(-7)` on restore — method does not exist
- Tried `authenticator.getPublicKeyAlgorithm()` to verify round-trip — method does not exist
- Looked for a builder or constructor that accepts the algorithm — none exists in the public API

### Root cause
`io.vertx.ext.auth.webauthn.Authenticator` holds the algorithm internally but exposes no getter or setter for it. The field is used during the WebAuthn registration ceremony (handled internally by the Vert.x/Quarkus extension) but is not part of the public API surface. Storing and restoring it is a no-op: the value is written to JSON but can never be read back onto the object.

### Fix
Omit `publicKeyAlgorithm` from the stored credential entirely. WebAuthn assertion verification (the login flow) does not require the algorithm field to be set on the `Authenticator` — the extension handles verification using the public key and sign count, which can be persisted and restored normally:

```java
// ❌ includes unpersistable field
record StoredCredential(String username, String credentialId,
    String publicKey, int publicKeyAlgorithm, long counter, String aaguid) {}

// ✅ omit it entirely
record StoredCredential(String username, String credentialId,
    String publicKey, long counter, String aaguid) {}
```

Add a comment explaining the omission to prevent a future developer from adding it back:

```java
// Note: publicKeyAlgorithm is intentionally omitted.
// io.vertx.ext.auth.webauthn.Authenticator exposes no getter or setter
// for the algorithm field, so it cannot be persisted or restored.
```

### Why this is non-obvious
Including the algorithm in a stored credential is a reasonable, security-conscious decision — you want the stored record to accurately represent what was registered. The write succeeds without error, so the problem is invisible until you look for a restore path and find there isn't one. The Quarkus WebAuthn documentation does not describe the internal structure of `Authenticator` or flag this limitation.

---

## Quarkus WebAuthn config keys use wrong names — silently ignored, no warning

**ID:** GE-0045
**Stack:** Quarkus 3.9.5 (`quarkus-security-webauthn`)
**Symptom:** WebAuthn extension starts normally, no warnings, no errors. Relying party name, ID, and origin are not what was configured — the extension is using its defaults.
**Context:** When configuring `quarkus-security-webauthn` via `application.properties`. Common abbreviated key names (`rp.id`, `rp.name`, `origins`) look plausible but are wrong.

### What was tried (didn't work)

- Set `quarkus.webauthn.rp.id=localhost` — silently ignored, no warning
- Set `quarkus.webauthn.rp.name=RemoteCC` — silently ignored, no warning
- Set `quarkus.webauthn.origins=http://localhost:7777` — silently ignored, no warning

No `Unrecognized configuration key` warning was produced for these — the extension consumed them without applying them.

### Root cause

The `WebAuthnRunTimeConfig` interface uses SmallRye Config field names that differ from what abbreviations suggest:

- `relyingParty` (a `RelyingPartyConfig` group) → kebab-case: `relying-party`, not `rp`
- `origin` (singular `Optional<String>`) → `origin`, not `origins`

Because `quarkus.webauthn.rp.*` and `quarkus.webauthn.origins` are not recognised config keys for this extension, Quarkus silently drops them without warning.

### Fix

```properties
# Correct keys (Quarkus 3.9.5)
quarkus.webauthn.relying-party.id=localhost
quarkus.webauthn.relying-party.name=RemoteCC
quarkus.webauthn.origin=http://localhost:7777

# Production env vars
# QUARKUS_WEBAUTHN_RELYING_PARTY_ID=your-domain.com
# QUARKUS_WEBAUTHN_RELYING_PARTY_NAME=YourApp
# QUARKUS_WEBAUTHN_ORIGIN=https://your-domain.com
```

### Why this is non-obvious

`rp` is the standard WebAuthn spec abbreviation for "Relying Party" — it appears in the W3C spec, the JavaScript API, and most WebAuthn libraries. Using `rp.id` and `rp.name` is natural. The fact that Quarkus uses `relying-party` (the full name, kebab-cased) isn't discoverable from docs. The silent failure — no warning, working extension, just wrong config — makes it very hard to notice that registration is using default values instead of your own.

*Score: 12/15 · Included because: silent failure with plausible-looking keys; standard spec abbreviation misleads; WebAuthn is security-critical · Reservation: may be fixed in Quarkus 3.10+; narrow to this extension*

---

## WebAuthn session cookie encryption key is `quarkus.http.auth.session.encryption-key` — not documented in WebAuthn extension docs

**ID:** GE-0046
**Stack:** Quarkus 3.9.5 (`quarkus-security-webauthn`)
**Symptom:** On startup: `WARN [io.qua.sec.web.WebAuthnRecorder] Encryption key was not specified for persistent WebAuthn auth, using temporary key`. A new random key is generated per JVM start, so any cookie issued before restart is invalid — users must re-authenticate on every server restart.
**Context:** Configuring `quarkus-security-webauthn` for production where session persistence is required.

### Description

The property that controls the AES-256 key used to encrypt WebAuthn session cookies belongs to `HttpConfiguration` (the generic Quarkus HTTP layer), not to the WebAuthn extension itself. It is documented on `HttpConfiguration.encryptionKey` in the Quarkus javadoc but not mentioned anywhere in the WebAuthn extension documentation.

The field name `encryptionKey` with a `@ConfigItem(name="auth.session.encryption-key")` annotation produces the full property path `quarkus.http.auth.session.encryption-key` — only visible via bytecode inspection.

### Fix

```properties
# application.properties — dev profile (stable key survives restarts)
%dev.quarkus.http.auth.session.encryption-key=<any-string-longer-than-16-chars>

# Production: set via environment variable
# QUARKUS_HTTP_AUTH_SESSION_ENCRYPTION_KEY=<secret-min-17-chars>
```

The key is hashed with SHA-256 before use, so the raw value doesn't need to be a specific byte length — just > 16 characters (Quarkus enforces this minimum).

### Why it's not obvious

- The WebAuthn extension docs make no mention of an encryption key config property.
- Guessing from the `HttpConfiguration` field name `encryptionKey` → `quarkus.http.encryption-key` produces an `Unrecognized configuration key` warning and is silently ignored.
- The actual property name is only visible in the `@ConfigItem(name=...)` annotation on the field, which requires decompiling `HttpConfiguration.class`.
- The property semantically belongs to "WebAuthn session persistence" but physically belongs to "Quarkus HTTP configuration."

### Caveats

- Value must be > 16 characters (enforced at runtime)
- The same property is shared with form-based auth
- In production, treat this as a secret — rotation invalidates all active sessions

*Score: 13/15 · Included because: production-impacting silent failure; genuinely undocumented in the WebAuthn extension; only discoverable via bytecode · Reservation: none identified*

---

## Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean

**ID:** GE-0077
**Stack:** Quarkus 3.9.x, Vert.x 4.5.x, Java 11+
**Labels:** `#pattern` `#quarkus` `#java`
**What it achieves:** Overrides a third-party handler registered in a private `Map` field without forking the library, using CDI startup lifecycle to ensure the patch runs before any requests arrive.
**Context:** The Vert.x WebAuthn extension (`WebAuthnImpl`) holds a private `Map<String, Attestation> attestations` field. The built-in `NoneAttestation` handler rejects Apple passkeys (non-zero AAGUID). There is no public API to swap handlers.

### The technique

```java
@ApplicationScoped
public class WebAuthnPatcher {
    @Inject WebAuthnSecurity webAuthnSecurity;

    void onStart(@Observes StartupEvent event) {
        try {
            var webAuthn = webAuthnSecurity.getWebAuthn(); // returns WebAuthnImpl
            Field field = findField(webAuthn.getClass(), "attestations");
            field.setAccessible(true);
            @SuppressWarnings("unchecked")
            var attestations = (Map<String, Attestation>) field.get(webAuthn);
            attestations.put("none", new LenientNoneAttestation());
        } catch (Exception e) {
            LOG.warnf("WebAuthnPatcher: patch failed — %s", e.getMessage());
        }
    }

    private static Field findField(Class<?> clazz, String name) {
        while (clazz != null) {
            try { return clazz.getDeclaredField(name); }
            catch (NoSuchFieldException e) { clazz = clazz.getSuperclass(); }
        }
        return null;
    }
}
```

### Why this is non-obvious
Most developers would fork the library or configure it out of the code path. The reflection approach avoids forking while remaining fully encapsulated. Vert.x jars are not JPMS modules (no `module-info.class`), so they're in the unnamed module and `setAccessible(true)` works without `--add-opens` flags on Java 11+. The `Map` is a regular `HashMap`, so `put()` is safe at startup.

*Score: 12/15 · Included because: elegant pattern for overriding third-party behaviour without forking; module access detail is genuinely undocumented · Reservation: slightly specific to Quarkus/Vert.x setup*

---

## Quarkus WebAuthn Actual HTTP Endpoint Paths (Only Discoverable via Bytecode)

**ID:** GE-0078
**Stack:** Quarkus 3.9.x (`quarkus-security-webauthn`), Vert.x 4.5.x

**What exists:** The Quarkus WebAuthn extension registers four HTTP endpoints under the non-application root (`/q/`):

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/q/webauthn/register` | POST | Step 1: server returns WebAuthn challenge options |
| `/q/webauthn/login` | POST | Step 1: server returns WebAuthn login challenge |
| `/q/webauthn/callback` | POST | Step 2: client submits credential/assertion |
| `/q/webauthn/webauthn.js` | GET | Quarkus-provided JS helper library |

**Why it's undocumented:** The Quarkus WebAuthn guide does not list these paths explicitly. The paths appear only as string constants in `WebAuthnRecorder.class` — discoverable via:
```bash
javap -verbose WebAuthnRecorder.class | grep "webauthn/"
```

**Common mistake:** Most WebAuthn tutorials describe a two-step REST pattern with `/options` and `/finish` endpoints. Quarkus uses a single-step per phase: there are no `/options` or `/finish` endpoints.

**Verification:**
```bash
curl http://localhost:7777/q/webauthn/webauthn.js           # 200 (JS helper)
curl -X POST http://localhost:7777/q/webauthn/register \
  -H 'Content-Type: application/json' -d '{}'               # 400 (route exists)
curl -X POST http://localhost:7777/q/webauthn/register/options # 404 (doesn't exist)
```

*Score: 13/15 · Included because: genuinely absent from official docs, only findable via bytecode inspection, common wrong assumption causes hours of debugging · Reservation: Quarkus-version-specific*

---

## Quarkus WebAuthn generates a new random session key on restart — REST APIs return 401, WebSocket stays alive

**ID:** GE-0126
**Stack:** Quarkus 3.9.x, quarkus-security-webauthn
**Symptom:** After a server restart, REST API calls from the browser return 401 silently (if errors are swallowed in `.catch()`), while an already-open WebSocket connection continues working. The UI appears functional (e.g. terminal displays content) but all authenticated HTTP requests fail.
**Context:** Running Quarkus WebAuthn in production mode without setting `QUARKUS_HTTP_AUTH_SESSION_ENCRYPTION_KEY`. A WARN log is emitted at startup: `"Encryption key was not specified for persistent WebAuthn auth, using temporary key XYZ="`. The key differs on every restart, so session cookies encrypted with the previous key are rejected.

### What was tried (didn't work)
- Assumed the WebSocket message handler was broken (wrong)
- Switched to REST API fetch calls (still silent 401)
- Added console logging (revealed nothing — JAR hadn't been rebuilt)

### Root cause
Quarkus uses the encryption key to sign session cookies. Without a stable key, every restart invalidates all existing cookies. The WebSocket is unaffected because it authenticates at connection time and keeps the TCP connection alive — new cookies are only checked on new connections.

### Fix
Set a stable session encryption key:

```properties
# application.properties
%prod.quarkus.http.auth.session.encryption-key=<secret-min-17-chars>
```

Or via env var: `QUARKUS_HTTP_AUTH_SESSION_ENCRYPTION_KEY=<secret>`.

### Why non-obvious
The WARN log is easy to miss. The WebSocket-alive / REST-dead symptom actively misleads — it implies the user is logged in (terminal works) but somehow not (API fails). Developers look at CORS, session config, or the WebSocket handler rather than a key rotation issue.

**See also:** GE-0046 (the undocumented config property path and how to discover it)

*Score: 13/15 · Included because: WebSocket-alive/REST-dead symptom is uniquely misleading; caused multiple debugging sessions; fix is one env var once you know what to set · Reservation: none*

---

## `quarkus.webauthn.login-page` defaults to `/login.html` — undocumented, causes 404 on protected routes

**ID:** GE-0128
**Stack:** Quarkus 3.9.x, quarkus-security-webauthn
**Symptom:** Accessing a path protected by `quarkus.http.auth.permission.*.policy=authenticated` without an auth cookie redirects to `/login.html`, which returns 404 if no such page exists. The actual login page at a different path is never reached.
**Context:** `quarkus-security-webauthn` has a runtime config property `loginPage()` on `WebAuthnRunTimeConfig` defaulting to `/login.html`. Not mentioned in Quarkus WebAuthn documentation. Only discoverable by decompiling the config class:

```bash
jar xf ~/.m2/repository/io/quarkus/quarkus-security-webauthn/3.9.5/quarkus-security-webauthn-3.9.5.jar
javap io/quarkus/security/webauthn/WebAuthnRunTimeConfig.class
# → public abstract java.lang.String loginPage();
```

### Fix
```properties
quarkus.webauthn.login-page=/auth/login
```

### Why non-obvious
The Quarkus WebAuthn docs do not mention `login-page` or `/login.html`. The symptom (redirect to 404) looks like a routing misconfiguration rather than a missing property. Zero discoverability without javap or source reading.

*Score: 11/15 · Included because: zero discoverability (requires javap), high breadth (every WebAuthn app with custom login path), easy to hit · Reservation: only applies when not using the default /login.html*
