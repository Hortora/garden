**Type:** undocumented
**Submission ID:** GE-0128
**Date:** 2026-04-09
**Project:** remotecc
**Stack:** Quarkus 3.9.x, quarkus-security-webauthn
**Suggested target:** `quarkus/testing.md` (existing file)

---

## quarkus.webauthn.login-page defaults to /login.html — not documented, only discoverable via javap

**Symptom:** Accessing a path protected by `quarkus.http.auth.permission.*.policy=authenticated` without an auth cookie redirects to `/login.html`, which returns `Resource not found` (404) if no such page exists. The actual login page at a different path (e.g. `/auth/login`) is never reached.

**Context:** `quarkus-security-webauthn` extension has a runtime config property `loginPage()` on `WebAuthnRunTimeConfig`. Its default value is `/login.html`. This is not mentioned in the Quarkus WebAuthn documentation. The only way to discover it is to decompile the config class:

```bash
jar xf ~/.m2/repository/io/quarkus/quarkus-security-webauthn/3.9.5/quarkus-security-webauthn-3.9.5.jar
javap io/quarkus/security/webauthn/WebAuthnRunTimeConfig.class
# → public abstract java.lang.String loginPage();
```

**Fix:** Add to `application.properties`:
```properties
quarkus.webauthn.login-page=/auth/login
```

**Why non-obvious:** The Quarkus WebAuthn getting-started docs and configuration reference do not mention `login-page` or `/login.html`. The symptom (redirect to 404) looks like a routing misconfiguration rather than a missing property. Only discoverable by decompiling the runtime config interface or stumbling across the WARN in the logs when `loginPage()` is overridden.

*Score: 11/15 · Included because: zero discoverability (requires javap or source reading), high breadth (every Quarkus WebAuthn app with a custom login path), easy to hit · Reservation: only applies when you don't use Quarkus's default /login.html*
