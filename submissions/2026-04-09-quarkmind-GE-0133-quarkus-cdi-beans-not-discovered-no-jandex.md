**Submission ID:** GE-0133
**Date:** 2026-04-09
**Type:** gotcha
**Project:** quarkmind (cross-project — any Quarkus app consuming a third-party jar)

## Quarkus CDI silently ignores `@ApplicationScoped` beans in jars without a Jandex index

### Symptom

CDI `Unsatisfied dependency` at Quarkus startup (or `@QuarkusTest` launch) for
a type that is clearly `@ApplicationScoped` in a third-party jar on the
classpath. The annotated class exists, the jar is present, the dependency
compiles — but Quarkus doesn't find the bean.

```
Found 2 deployment problems:
[1] Unsatisfied dependency for type io.casehub.core.spi.CaseFileRepository
[2] Unsatisfied dependency for type io.casehub.worker.TaskRepository
```

### Context

Quarkus uses Jandex for CDI bean discovery. If a jar does not contain
`META-INF/jandex.idx`, Quarkus will not scan it for beans — not even if
the beans are correctly annotated with `@ApplicationScoped`.

This only affects third-party jars over which you have no build control (or
library modules built without the Jandex Maven plugin). First-party source
in the application module is always scanned.

### What was tried (didn't work)

- Verified the jar is on the classpath — it compiles fine ✓
- Verified the beans have `@ApplicationScoped` — confirmed via `javap` ✓
- Adding the dependency — already present ✓
- Rebuilding with `-DskipTests` — no effect

### Root cause

`META-INF/jandex.idx` is missing from the third-party jar. Quarkus skips
the jar entirely during CDI discovery. The "Unsatisfied dependency" error
gives no hint about *why* — it looks identical to a genuine missing
implementation.

```bash
# Verify: check if jandex.idx is present in the jar
jar tf path/to/the.jar | grep jandex
# If no output → the jar has no Jandex index → beans will not be discovered
```

### Fix

Add `quarkus.index-dependency` config to force Quarkus to scan the jar:

```properties
# application.properties
# Replace groupId/artifactId with the actual artifact identifiers
quarkus.index-dependency.my-lib.group-id=io.casehub
quarkus.index-dependency.my-lib.artifact-id=casehub-persistence-memory
```

The key name (`my-lib`) is arbitrary — it's just a label for the config block.
Multiple jars can be forced by using different labels.

This config is **not in the Quarkus CDI guide** — it's documented in the
Class Loading Reference under "Jandex". Most developers look in the CDI
section first.

### Why non-obvious

The error message "Unsatisfied dependency" implies the implementation is
missing, not that the implementation is present but invisible. A developer
who added the jar and verified the annotations are present has no obvious
next step — nothing in the error points to Jandex or scanning.

### Stack

Quarkus 3.x (all versions that use Jandex for bean discovery)

*Score: 14/15 · Included because: silent failure with misleading symptom, affects every Quarkus consumer of third-party jars, fix is undocumented in the CDI guide · Reservation: none*
