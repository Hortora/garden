**Type:** gotcha
**Submission ID:** GE-0145
**Date:** 2026-04-09
**Project:** permuplate (IntelliJ plugin Gradle build)

## Gradle 8.6 Fails Cryptically When JAVA_HOME Points to Java 26

**Stack:** Gradle 8.6, Java 26, IntelliJ Platform Gradle Plugin

**Symptom:**
`./gradlew test` exits immediately with an error during Gradle initialization — something like `JavaVersion.parse("26")` throws an exception, with no obvious indication that the JDK version is the problem. The error may surface as a Kotlin or Gradle internal exception, not a clear "unsupported Java version" message.

**Context:**
Occurs when the shell's default `java -version` is Java 26 and no explicit `JAVA_HOME` is set. Gradle 8.6 parses the JDK version string during initialization and does not handle single-digit major versions >= 26 in its version enum.

**What was tried:**
Running `./gradlew test` directly from the shell, assuming Gradle would use whatever JDK was available.

**Root cause:**
Gradle 8.6's `JavaVersion` enum predates Java 26 and cannot parse the version string `"26"`. The enum only covers versions up to a fixed ceiling. Java 26 is beyond what Gradle 8.6 supports.

**Fix:**
Set `JAVA_HOME` explicitly to a supported JDK before invoking Gradle:

```bash
JAVA_HOME=/opt/homebrew/Cellar/openjdk@17/17.0.18 ./gradlew test
```

Or add to your shell profile / project scripts:

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

**Why non-obvious:**
The error message names an internal Gradle class (`JavaVersion.parse`) rather than saying "unsupported JDK". A developer with Java 26 as their default would not immediately connect the error to their JDK version, especially if the project has no explicit `java.toolchain` config in `build.gradle`.

**Suggested target:** `tools/gradle.md` (new file, header: `# Gradle Gotchas and Techniques`)

*Score: 10/15 · Included because: cryptic symptom, common setup issue with modern JDKs · Reservation: Gradle version-specific, may be fixed in later Gradle releases*
