# Maven Gotchas

Discovered working with Maven build configuration.

---


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
