**Submission ID:** GE-0076
**Date:** 2026-04-07
**Project:** remotecc
**Type:** gotcha
**Suggested target:** `quarkus/quarkus-config.md` (new file — header: `# Quarkus Configuration Gotchas`)

## -D Flags After -jar Don't Override Config Expressions in Quarkus

**Stack:** Quarkus 3.x (all versions), Java 11+

**Symptom:** `java -jar app.jar -Dquarkus.http.port=7778` has no effect — the server still starts on the port defined in `application.properties`. No error or warning is logged.

**Context:** When `application.properties` contains an expression like `quarkus.http.port=${remotecc.port}`, passing `-Dquarkus.http.port=7778` after `-jar` is silently ignored because the expression takes precedence over the program-argument system property. The server starts on whatever `remotecc.port` resolves to (e.g. 7777).

**What was tried:**
- `java -jar app.jar -Dquarkus.http.port=7778` — no effect
- `java -jar app.jar -Dremotecc.mode=agent -Dquarkus.http.port=7778` — mode applied, port ignored
- Expected the JVM system property to override the config file value

**Root cause:** Two separate issues combine:
1. `-D` flags placed *after* `-jar` are program arguments (args to `main()`), not JVM system properties. Quarkus does process some of them as config overrides, but not all.
2. Config expressions (`${remotecc.port}`) resolve through Quarkus's SmallRye Config chain. An expression-based property takes its value from the *source* property (`remotecc.port`), not from a directly-set override of the computed property name.

**Fix:**
```bash
# Option 1: Put -D flags BEFORE -jar (real JVM system properties)
java -Dquarkus.http.port=7778 -jar app.jar

# Option 2: Override the SOURCE property the expression is based on
java -jar app.jar -Dremotecc.port=7778
# (because application.properties has: quarkus.http.port=${remotecc.port})
```

**Why non-obvious:** Both approaches look identical at a glance. The man page for `java` describes `-D` as a system property, but doesn't clarify the before/after `-jar` distinction. Quarkus's config expression resolution is an additional layer that isn't surfaced in error messages.

*Score: 11/15 · Included because: common mistake, silent failure, affects Quarkus specifically with expression-based config · Reservation: slightly Quarkus-specific*
