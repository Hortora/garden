# Quarkus CDI Techniques

---

## Use `@UnlessBuildProfile("prod")` to strip debug/QA beans from production at CDI level

**ID:** GE-0033
**Stack:** Quarkus 3.x (all versions with `io.quarkus.arc.profile.UnlessBuildProfile`)
**Labels:** `#quarkus` `#security`
**What it achieves:** A CDI bean annotated with `@UnlessBuildProfile("prod")` does not exist in the production profile — no runtime check, no auth requirement, no config flag. The endpoint is simply not registered. Zero production security surface.
**Context:** Dev/test-only REST endpoints (QA harness, debug tools, admin shortcuts) that must never be accessible in production, regardless of configuration drift.

### The technique

```java
import io.quarkus.arc.profile.UnlessBuildProfile;

@UnlessBuildProfile("prod")   // Bean doesn't exist in the prod profile — at all
@Path("/sc2/debug")
@Produces(MediaType.APPLICATION_JSON)
public class ScenarioResource {

    @Inject ScenarioRunner scenarioRunner;

    @POST
    @Path("/scenario/{name}")
    @Consumes(MediaType.WILDCARD)
    public Response runScenario(@PathParam("name") String name) {
        scenarioRunner.run(name);
        return Response.noContent().build();
    }
}
```

The complementary annotation `@IfBuildProfile("dev")` activates a bean **only** in the dev profile. For something that should exist in dev and test but not prod, `@UnlessBuildProfile("prod")` is the right choice.

Both annotations work at Quarkus build time — the bean is excluded from the CDI graph at augmentation, not at runtime. No reflection config needed for native image.

### Why this is non-obvious
Most developers reach for `@RolesAllowed("admin")`, a profile-specific config property, or a feature flag — all of which are runtime checks that can be misconfigured. The CDI-level exclusion means the endpoint literally cannot be called in prod because the bean does not exist. There is no runtime path to it at all. The annotation is a Quarkus Arc extension, not a standard CDI or Jakarta EE annotation, so developers unfamiliar with Quarkus Arc internals won't know it exists.

### When to use it
- Debug REST endpoints, QA harness APIs, scenario injection endpoints
- Any bean that should be completely absent from production — not just locked down

Not appropriate for features that should be configurable at runtime — use `@ConfigProperty` for that. This is a build-time exclusion.

**See also:** GE-0052 (undocumented anyOf/allOf attributes on @UnlessBuildProfile — extends this technique)

*Score: 14/15 · Included because: CDI-level exclusion is strictly better than runtime guards for truly dev-only functionality; annotation is obscure enough that most Quarkus developers don't know it exists · Reservation: none identified*

---

## `@UnlessBuildProfile` on a bean causes "Unsatisfied dependency" in any bean that injects it without a matching profile guard

**ID:** GE-0066
**Stack:** Quarkus 3.x, Quarkus Arc (all versions with profile-based CDI)
**Symptom:** Adding `@UnlessBuildProfile("X")` to bean `A` causes every other bean that injects `A` directly (not via `Instance<A>`) to fail at startup in profile `X` with: `Unsatisfied dependency for type A and qualifiers [@Default]`. The failure is a CDI build-time error — the application doesn't even start.
**Context:** Any Quarkus application using profile-based CDI exclusion where the excluded bean is injected by profile-unguarded consumers.

### What was tried (didn't work)

- Added `@UnlessBuildProfile("sc2")` to `SimulatedGame`
- `CaseFileResource` and `IntentResource` still injected `SimulatedGame` directly
- Application failed to start in `%sc2` profile with "Unsatisfied dependency"

### Root cause

Quarkus Arc resolves CDI injection points at build time. When a bean is excluded via `@UnlessBuildProfile`, it disappears from the CDI graph entirely in that profile. Any other bean with a direct `@Inject SimulatedGame` field becomes invalid — the injection point has no candidate. Unlike Spring's conditional beans (which produce null), Quarkus treats this as a deployment error.

### Fix

Two options depending on intent:

**Option 1 — Also guard the consumer** (if the consumer is also profile-specific):
```java
@UnlessBuildProfile("sc2")  // same guard as the dependency
@ApplicationScoped
public class CaseFileResource { ... }
```

**Option 2 — Switch to `Instance<T>` injection** (if the consumer must exist in all profiles):
```java
@Inject Instance<SimulatedGame> simulatedGame;  // optional injection

public void doWork() {
    if (simulatedGame.isResolvable()) {
        simulatedGame.get().tick();
    }
}
```

`Instance<T>` is CDI's optional injection mechanism — `isResolvable()` returns false when the bean doesn't exist in the current profile. The injection point itself is always valid.

### Why this is non-obvious

The error looks like a misconfiguration ("why can't it find SimulatedGame?") rather than a profile design issue. Developers familiar with Spring's `@ConditionalOnProfile` expect null or a default fallback, not a hard startup failure. The `Instance<T>` pattern is the correct CDI solution but requires knowing it exists.

*Score: 13/15 · Included because: hard startup failure with a misleading error message, combined with wrong mental model from Spring experience · Reservation: none identified*

---

## `HttpAuthenticationMechanism` injections resolve before `@Observes StartupEvent` fires

**ID:** GE-0062
**Stack:** Quarkus 3.9.x
**Symptom:** Custom `HttpAuthenticationMechanism` injects a stateful `@ApplicationScoped` service. That service is initialized via a `@Observes StartupEvent` handler. All `@QuarkusTest` authenticated requests return 401. The service's `getKey()` returns `Optional.empty()` even though the test config property is set and the StartupEvent observer fires.
**Context:** Applies when a custom `HttpAuthenticationMechanism` injects a service whose state is set by a `@Observes StartupEvent` handler, running under `@QuarkusTest`.

### What was tried

- Verified the `%test.*` config property was correctly set → confirmed set
- Verified the StartupEvent observer was firing → confirmed firing
- Verified CDI injection was wiring up correctly → confirmed
- Still 401 because `getKey()` returned empty at request time

### Root cause

In Quarkus, `HttpAuthenticationMechanism` implementations process incoming requests before `@Observes StartupEvent` observers fire. CDI construction and `@PostConstruct` happen first, then HTTP server opens, then `StartupEvent` fires. When the first test request arrives, the auth mechanism calls `service.getKey()` — but `initServer()` (which sets `resolvedKey`) hasn't been called yet.

### Fix

Add `@PostConstruct` to the injected service to eagerly load config-sourced state at CDI construction time:

```java
@PostConstruct
void autoInit() {
    // Eagerly load from config — runs before StartupEvent observers and before
    // the HTTP server accepts requests. Safe as long as no file I/O here.
    resolvedKey = loadFromConfig();
}
```

The `StartupEvent` handler still runs later and can extend the work (file I/O, key generation) idempotently. The `@PostConstruct` only handles the cheap config-load path.

### Why non-obvious

`@Observes StartupEvent` is the standard Quarkus initialization idiom. Nothing in the Quarkus docs warns that auth mechanisms process requests before startup observers fire. The symptom (401 on a valid test key) points to config or auth logic, not initialization timing.

*Score: 13/15 · Included because: non-obvious CDI/startup ordering in the auth mechanism path, only discoverable by hitting the failure · Reservation: Quarkus-specific*

---

## Quarkus CDI silently ignores `@ApplicationScoped` beans in jars without a Jandex index

**ID:** GE-0133
**Stack:** Quarkus 3.x (all versions that use Jandex for bean discovery)
**Symptom:** CDI `Unsatisfied dependency` at Quarkus startup for a type that is clearly `@ApplicationScoped` in a third-party jar on the classpath. The annotated class exists, the jar is present, the dependency compiles — but Quarkus doesn't find the bean.

```
Found 2 deployment problems:
[1] Unsatisfied dependency for type io.casehub.core.spi.CaseFileRepository
[2] Unsatisfied dependency for type io.casehub.worker.TaskRepository
```

**Context:** Quarkus uses Jandex for CDI bean discovery. If a jar does not contain `META-INF/jandex.idx`, Quarkus will not scan it for beans — not even if the beans are correctly annotated. Only affects third-party jars over which you have no build control; first-party source in the application module is always scanned.

### What was tried (didn't work)
- Verified the jar is on the classpath — compiles fine
- Verified the beans have `@ApplicationScoped` — confirmed via `javap`
- Adding the dependency — already present
- Rebuilding with `-DskipTests` — no effect

### Root cause
`META-INF/jandex.idx` is missing from the third-party jar. Quarkus skips the jar entirely during CDI discovery. The "Unsatisfied dependency" error gives no hint about why — it looks identical to a genuine missing implementation.

```bash
# Check if jandex.idx is present in the jar
jar tf path/to/the.jar | grep jandex
# If no output → no Jandex index → beans will not be discovered
```

### Fix
Add `quarkus.index-dependency` config to force Quarkus to scan the jar:

```properties
# application.properties
quarkus.index-dependency.my-lib.group-id=io.casehub
quarkus.index-dependency.my-lib.artifact-id=casehub-persistence-memory
```

The key name (`my-lib`) is arbitrary. Multiple jars can be forced using different labels. This config is **not in the Quarkus CDI guide** — it is documented in the Class Loading Reference under "Jandex".

### Why non-obvious
"Unsatisfied dependency" implies the implementation is missing, not that it is present but invisible. A developer who added the jar and verified the annotations has no obvious next step — nothing in the error points to Jandex or scanning.

*Score: 14/15 · Included because: silent failure with misleading symptom, affects every Quarkus consumer of third-party jars, fix is undocumented in the CDI guide · Reservation: none*

---

## Quarkus JAX-RS resource without `@ApplicationScoped` silently breaks instance-level caches

**ID:** GE-0148
**Stack:** Quarkus 3.34.2, RESTEasy / Jakarta REST
**Symptom:** A JAX-RS resource with an in-memory cache field never hits the cache — every request performs a fresh fetch. No error, no warning. Cache size stays at 1 on every inspection.
**Context:** Any JAX-RS resource class that holds mutable state (cache, counter, list) without an explicit CDI scope annotation.

### Root cause
Quarkus JAX-RS resources default to `@RequestScoped` when no CDI scope is declared. A new instance is created for every HTTP request. Any instance-level state is discarded after each request — the field initialiser runs fresh every time.

### Fix
Add `@ApplicationScoped` to any JAX-RS resource that holds state:

```java
// WRONG — new instance per request, cache never hits
@Path("/api/sprites")
public class SpriteProxyResource {
    private final Map<String, byte[]> cache = new ConcurrentHashMap<>();
}

// FIX
@ApplicationScoped
@Path("/api/sprites")
public class SpriteProxyResource {
    private final Map<String, byte[]> cache = new ConcurrentHashMap<>();
}
```

### Why non-obvious
The default in JAX-RS (and Spring MVC) is typically singleton/application scope. Quarkus follows the CDI spec, not the JAX-RS convention. No warning is emitted when a request-scoped resource has state. The cache appears to "work" — it just never hits.

*Score: 12/15 · Included because: contradicts JAX-RS developer mental model, completely silent failure, cache appears to work · Reservation: CDI spec is clear on this, it's a knowledge gap not a Quarkus bug*
