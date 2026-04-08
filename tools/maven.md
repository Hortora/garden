# Maven Gotchas

Discovered working with Maven build configuration.

---

## Surefire profile excludes inherit from default config unless `combine.self="override"` is used

**Stack:** Maven 3.x, maven-surefire-plugin 3.2.5 (confirmed; likely all 3.x)
**Symptom:** A Maven profile that adds `<includes>` to surefire runs zero tests. No error. The pattern matches test files that exist, but 0 tests run.
**Context:** When the default surefire config has `<excludes>` and a profile overrides surefire with `<includes>`, the profile INHERITS the excludes from the default config. Excludes beat includes, producing zero results silently.

### What was tried (didn't work)
- Added `<includes><include>**/*E2ETest.java</include></includes>` to profile — 0 tests (default excludes still active)
- Added `<excludes/>` (empty) in profile — Maven merges with default, not replaces; default excludes remain active

### Root cause
Maven merges plugin configuration from `<build>` and `<profile>` rather than replacing it. The profile's `<configuration>` inherits all default settings including `<excludes>`. The included pattern is applied but so are the inherited excludes — and excluded beats included.

### Fix
Use `combine.self="override"` on `<excludes>` in the profile to tell Maven to replace that element entirely:

```xml
<!-- Default build: exclude E2E tests from normal run -->
<plugin>
  <artifactId>maven-surefire-plugin</artifactId>
  <configuration>
    <excludes>
      <exclude>**/*E2ETest.java</exclude>
    </excludes>
  </configuration>
</plugin>

<!-- -Pe2e profile: run ONLY E2E tests -->
<profile>
  <id>e2e</id>
  <build><plugins><plugin>
    <artifactId>maven-surefire-plugin</artifactId>
    <configuration>
      <includes>
        <include>**/*E2ETest.java</include>
      </includes>
      <!-- replaces the inherited <excludes> with empty -->
      <excludes combine.self="override"/>
    </configuration>
  </plugin></plugins></build>
</profile>
```

### Why this is non-obvious
Most developers expect a profile to *override* the relevant section, not *merge* with it. An empty `<excludes/>` looks like it should clear the excludes, but Maven treats it as "nothing to add" and parent values remain. `combine.self="override"` is the escape hatch but requires knowing it exists. The symptom (0 tests, no error) gives no hint that inherited configuration is the cause.

---

## Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other

**ID:** GE-0039
**Stack:** Maven Surefire 3.x, Panama FFM, Java 22+, macOS AArch64
**Labels:** `#testing` `#ci-cd` `#panama-ffm`
**What it achieves:** Prevents JVM crashes caused by Panama FFM native I/O calls in one test class corrupting the Panama downcall infrastructure for subsequent test classes in the same JVM process.
**Context:** Test suite using Panama FFM to call POSIX libc functions (`write`, `read`, `tcgetattr`, `ioctl`) on PTY file descriptors. The SIGTRAP gotcha (GE-0038) requires this fix.

### The technique

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.2.5</version>
    <configuration>
        <argLine>--enable-native-access=ALL-UNNAMED</argLine>
        <!-- Fork a fresh JVM per test class — prevents Panama FFM native I/O
             state from corrupting downcall infrastructure across class boundaries -->
        <reuseForks>false</reuseForks>
    </configuration>
</plugin>
```

The default surefire configuration (`reuseForks=true`) runs all test classes in the same forked JVM. When Panama FFM is used to call native functions that do I/O on certain native fds, this can corrupt Panama's internal downcall state, causing SIGTRAP (exit 133) in the next test class that uses any Panama downcall.

`reuseForks=false` gives each test class a fresh JVM — corrupted state never crosses class boundaries.

### Why this is non-obvious
- The crash appears in the WRONG class (not the one that did the I/O)
- Both classes pass perfectly in isolation — making it look like an ordering problem
- Exit code 133 (SIGTRAP) gives no diagnostic information
- The obvious fix (ensure fds are closed) doesn't help — the problem is inside Panama FFM internals
- The fix is in the build config, not in the test code itself

### When to use it
Any Maven project that uses Panama FFM to call native I/O functions (`write`, `read`, `ioctl`, termios functions) and has multiple test classes using Panama FFM. The performance cost is one extra JVM startup per test class — usually negligible for small test suites.

**See also:** GE-0038 for the root cause (Panama FFM PTY SIGTRAP crash).

*Score: 11/15 · Included because: fix is a one-line config change; finding it requires knowing the root cause, which is extremely non-obvious · Reservation: specific to Panama FFM + PTY + macOS AArch64 combination*
