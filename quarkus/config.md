# Quarkus Config Gotchas and Techniques

---

## Use javap to find the actual Quarkus config property name from a field annotation

**ID:** GE-0047
**Stack:** Quarkus 3.9.5 (any version), Java `javap` (any JDK)
**Labels:** `#debugging` `#quarkus`
**What it achieves:** Definitively identifies the exact `application.properties` key for any Quarkus config field, bypassing docs that may be incomplete or misleading.
**Context:** When a guessed config key is silently ignored or produces an "Unrecognized configuration key" warning, and the docs don't clearly state the full property path.

### The technique

```bash
# 1. Extract the config class from the extension jar
cd /tmp
jar xf ~/.m2/repository/io/quarkus/quarkus-security-webauthn/3.9.5/\
quarkus-security-webauthn-3.9.5.jar \
io/quarkus/security/webauthn/WebAuthnRunTimeConfig.class

# 2. Dump the constant pool — all string constants including annotation values
javap -verbose io/quarkus/security/webauthn/WebAuthnRunTimeConfig.class \
  | grep "Utf8" | grep -v "java\|io\.\|sun\.\|Ljava\|Lio\|Code\|LineNumber"

# Key output lines (field name → config key name):
#   #5 = Utf8   origin           ← field name
#   #77 = Utf8  auth.session.encryption-key  ← @ConfigItem(name=...) value
#   #11 = Utf8  relyingParty     ← field name (maps to relying-party in kebab-case)
```

The `@ConfigItem(name=...)` or `@WithName(...)` annotation value is the fragment appended to the class's config prefix. If no `name=` override is present, Quarkus converts the field name from camelCase to kebab-case.

To find the prefix, check `META-INF/quarkus-config-roots.list` in the jar, then decompile that class:

```bash
jar xf <extension>.jar META-INF/quarkus-config-roots.list
cat META-INF/quarkus-config-roots.list
# → io.quarkus.security.webauthn.WebAuthnRunTimeConfig

# Decompile it and look for the @ConfigRoot prefix annotation
javap -verbose io/quarkus/security/webauthn/WebAuthnRunTimeConfig.class \
  | grep "prefix"
# → prefix="quarkus.webauthn"
```

Full property = prefix + `.` + kebab-case field name (or annotation override).

### Why this is non-obvious

Most developers would:
1. Check the official docs (often incomplete or lagging the actual code)
2. Guess from the Java field name (`encryptionKey` → `encryption-key`)
3. Try environment variable name conventions

The `@ConfigItem(name=...)` annotation overrides the field name convention entirely — `encryptionKey` with `name="auth.session.encryption-key"` produces `quarkus.http.auth.session.encryption-key`, not `quarkus.http.encryption-key`. This is invisible without reading the bytecode. `javap -verbose` exposes the full constant pool including annotation string values, making it reliable even for undocumented or mis-documented properties.

### When to use it

- Config key produces "Unrecognized configuration key" warning despite looking correct
- A warning says a value "was not specified" but you set it and it's still appearing
- Docs describe the field but not the full property path
- Trying to set a property from a transitive/internal Quarkus dependency

*Score: 12/15 · Included because: solves an entire class of Quarkus config debugging problems; the technique transfers to any annotation-driven framework; javap use for annotation inspection is genuinely non-obvious · Reservation: none identified*

---

## -D Flags After -jar Don't Override Config Expressions in Quarkus

**ID:** GE-0076
**Stack:** Quarkus 3.x (all versions), Java 11+
**Symptom:** `java -jar app.jar -Dquarkus.http.port=7778` has no effect — the server still starts on the port defined in `application.properties`. No error or warning is logged.
**Context:** When `application.properties` contains an expression like `quarkus.http.port=${remotecc.port}`, passing `-Dquarkus.http.port=7778` after `-jar` is silently ignored because the expression takes precedence over the program-argument system property.

### Root cause
Two separate issues combine:
1. `-D` flags placed *after* `-jar` are program arguments (args to `main()`), not JVM system properties.
2. Config expressions (`${remotecc.port}`) resolve through Quarkus's SmallRye Config chain. An expression-based property takes its value from the *source* property, not from a directly-set override of the computed property name.

### Fix
```bash
# Option 1: Put -D flags BEFORE -jar (real JVM system properties)
java -Dquarkus.http.port=7778 -jar app.jar

# Option 2: Override the SOURCE property the expression is based on
java -jar app.jar -Dremotecc.port=7778
# (because application.properties has: quarkus.http.port=${remotecc.port})
```

### Why non-obvious
Both approaches look identical at a glance. The java man page describes `-D` as a system property but doesn't clarify the before/after `-jar` distinction. Quarkus's config expression resolution is an additional layer that isn't surfaced in error messages.

*Score: 11/15 · Included because: common mistake, silent failure, affects Quarkus specifically with expression-based config · Reservation: slightly Quarkus-specific*
