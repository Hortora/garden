# Java / Maven Gotchas

---

## Maven aggregator pom requires `<packaging>pom</packaging>` — omitting it causes a cryptic build failure

**ID:** GE-0064
**Stack:** Maven 3.x (all versions)
**Symptom:** Adding a `<modules>` section to a pom.xml that has `<packaging>jar</packaging>` (or no packaging, which defaults to jar) causes the build to fail with: `'packaging' with value 'jar' is invalid`. The error appears before any modules are compiled.
**Context:** Any Maven project being converted from a single-module build to a multi-module aggregator by adding `<modules>` to the root pom.

### What was tried (didn't work)

- Added `<modules><module>scelight-mpq</module>...</modules>` to root pom
- Build failed immediately with packaging error

### Root cause

Maven requires that any pom declaring `<modules>` must use `<packaging>pom</packaging>`. This signals to Maven that this pom is an aggregator/reactor, not a compiled artifact. The jar packaging lifecycle is incompatible with the aggregator role.

### Fix

```xml
<project>
    <groupId>hu.scelight</groupId>
    <artifactId>scelight</artifactId>
    <version>3.1.3</version>
    <packaging>pom</packaging>    <!-- required when declaring <modules> -->

    <modules>
        <module>scelight-mpq</module>
        <module>scelight-s2protocol</module>
    </modules>
    ...
</project>
```

### Why this is non-obvious

The error message `'packaging' with value 'jar' is invalid` gives no hint that the fix is changing the packaging to `pom`. Developers debugging this typically check module paths, artifact IDs, or plugin configuration — not the packaging type. The Maven documentation covers this but it's in the multi-module guide, not surfaced when the error occurs.

*Score: 11/15 · Included because: the error message actively misleads — "invalid packaging" suggests the wrong packaging value, not a missing packaging declaration · Reservation: covered in Maven docs; experienced Maven developers know it*

---

## Maven ignores non-Java files in `src/main/java/` — resources must be in `src/main/resources/` or explicitly declared

**ID:** GE-0067
**Stack:** Maven 3.x (all versions), any project with non-Java files co-located with source
**Symptom:** A class loads a resource via `getClass().getResource("build/81009.dat")` and gets null at runtime, even though the `.dat` files clearly exist in the repository under `src/main/java/`. The JAR is built and on the classpath. No error — just a null resource reference that propagates silently into a null field.
**Context:** Any Maven project that stores non-Java files (`.dat`, `.properties`, `.json`, template files, etc.) alongside Java source in `src/main/java/` rather than the conventional `src/main/resources/`.

### What was tried (didn't work)

- Verified the `.dat` files exist in the source tree — they do
- Verified the JAR is on the classpath — it is
- Added the JAR to the classpath manually — still null
- Opened the JAR with `jar tf` — the `.dat` files were absent entirely

### Root cause

Maven's default resource processing only includes `src/main/resources/` in the final artifact. Files in `src/main/java/` are treated as Java source — the compiler processes `.java` files and ignores everything else. Non-Java files under `src/main/java/` are simply dropped from the JAR.

### Fix

**Option 1 — Move files to `src/main/resources/`** (canonical fix, mirrors the resource path exactly):
```
src/main/resources/hu/scelight/sc2/rep/s2prot/build/81009.dat
```

**Option 2 — Add a `<resources>` declaration** to include non-Java files from `src/main/java/`:
```xml
<build>
    <resources>
        <resource>
            <directory>src/main/java</directory>
            <excludes><exclude>**/*.java</exclude></excludes>
        </resource>
        <resource>
            <directory>src/main/resources</directory>
        </resource>
    </resources>
</build>
```

Option 2 is useful when source and resources are co-located (e.g. an extracted library that uses `getClass().getResource(...)` relative to the class file path).

Verify the fix worked:
```bash
jar tf target/myartifact.jar | grep "\.dat"
```

### Why this is non-obvious

The error manifests far from the cause: `Protocol.DEFAULT` is null, `parseReplay()` returns null, all parsing silently fails. Nothing warns you that resource files are missing from the JAR. The `.dat` files exist in the source tree and the JAR is on the classpath — both the things you'd check. The missing step (opening the JAR to see what's actually inside) is non-obvious.

*Score: 14/15 · Included because: silent null failure traceable only by inspecting JAR contents — a step most developers skip when the source files clearly exist · Reservation: none identified*
