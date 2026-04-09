**Submission ID:** GE-0134
**Date:** 2026-04-09
**Type:** gotcha
**Project:** quarkmind (cross-project — any multi-module Maven project with Quarkus library modules)

## `mvn install -DskipTests` runs Quarkus augmentation on library modules and fails if CDI is unsatisfied

### Symptom

`mvn install -DskipTests` fails on a library module (packaging: jar) that
has `quarkus-maven-plugin` wired with the `build` goal, because Quarkus
augmentation runs and finds unsatisfied CDI dependencies:

```
[ERROR] Build step io.quarkus.arc.deployment.ArcProcessor#validate threw an exception:
jakarta.enterprise.inject.spi.DeploymentException: Found 3 deployment problems:
[1] Unsatisfied dependency for type io.casehub.core.spi.CaseFileRepository
```

This happens even though the module is a library (`<packaging>jar</packaging>`)
and even though tests are skipped.

### Context

A library module provides CDI interfaces (e.g. `TaskBroker` that injects
`TaskRepository`) but relies on a sibling persistence module to provide the
implementations. During `mvn install -DskipTests` on just the library module,
the implementations are not on the classpath and augmentation fails.

### What was tried (didn't work)

- `mvn install -DskipTests` — augmentation still runs, fails
- `mvn install -Dmaven.test.skip=true` — same result

### Root cause

When `quarkus-maven-plugin` includes the `build` goal in `<executions>`, it
runs Quarkus augmentation during the `package` phase — regardless of whether
tests are skipped. This is the correct behaviour for runnable Quarkus
applications, but it is surprising for library modules that happen to use the
Quarkus build plugin.

### Fix

Add `-Dquarkus.build.skip=true` to skip the augmentation step:

```bash
mvn install -DskipTests -Dquarkus.build.skip=true
```

This produces a correctly compiled jar with all classes, without running
augmentation. The resulting jar is suitable as a library dependency.

### Why non-obvious

`-DskipTests` is universally understood to mean "skip testing". Developers
reasonably assume it also skips heavy build steps. Quarkus augmentation
is a compile-adjacent step that runs in the package phase, not the test phase,
so `-DskipTests` has no effect on it. The flag `-Dquarkus.build.skip=true`
exists but is not prominently documented in the Maven plugin docs — it's
only mentioned in passing in the native build guide.

### Stack

Quarkus Maven plugin 3.x (all versions)

*Score: 12/15 · Included because: counter-intuitive flag interaction, affects every multi-module Quarkus library project · Reservation: somewhat discoverable via Maven plugin docs*
