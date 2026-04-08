**Submission ID:** GE-0077
**Date:** 2026-04-07
**Project:** remotecc
**Type:** technique
**Labels:** #pattern #quarkus #java
**Suggested target:** `quarkus/quarkus-webauthn.md` (new file — header: `# Quarkus WebAuthn Gotchas and Techniques`)

## Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean

**Stack:** Quarkus 3.9.x, Vert.x 4.5.x, Java 11+

**Context:** The Vert.x WebAuthn extension (`WebAuthnImpl`) holds a private `Map<String, Attestation> attestations` field keyed by attestation format string (`"none"`, `"packed"`, `"apple"`, etc.). The built-in `NoneAttestation` handler rejects Apple passkeys (non-zero AAGUID). There is no public API to swap handlers.

**Technique:** Use a `@ApplicationScoped` Quarkus CDI bean that `@Observes StartupEvent` to access the `WebAuthnSecurity` bean, walk up to the concrete `WebAuthnImpl` via `getWebAuthn()`, find the private field via reflection, and swap the handler:

```java
@ApplicationScoped
public class WebAuthnPatcher {
    @Inject WebAuthnSecurity webAuthnSecurity;
    @Inject RemoteCCConfig config;

    void onStart(@Observes StartupEvent event) {
        if (!"server".equals(config.mode())) return;
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

**Why non-obvious:** Most developers would fork the library or configure it out of the code path. The reflection approach avoids forking while remaining fully encapsulated in one class. The `@Observes StartupEvent` pattern in Quarkus ensures the patch runs after CDI wiring but before any WebSocket connections arrive. The `Map` is a regular `HashMap` (not a concurrent or immutable map), so `put()` is safe at startup.

**Note on module access:** Vert.x jars are not JPMS modules (no `module-info.class`), so they're in the unnamed module and `setAccessible(true)` works without `--add-opens` flags on Java 11+.

*Score: 12/15 · Included because: elegant pattern for overriding third-party behaviour without forking; module access detail is genuinely undocumented · Reservation: slightly specific to Quarkus/Vert.x setup*
