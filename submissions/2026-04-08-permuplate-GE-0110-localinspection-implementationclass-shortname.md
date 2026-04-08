**Submission ID:** GE-0110
**Date:** 2026-04-08
**Type:** gotcha
**Suggested target:** `intellij-platform/inspections.md` (new file, new dir)
**File header needed:** `# IntelliJ Platform — Inspection Gotchas`

---

## `localInspection` in plugin.xml Requires `implementationClass` and Explicit `shortName`

**Stack:** IntelliJ Platform (any version), `plugin.xml` `<localInspection>` registration

**Symptom 1 — Wrong attribute name:**
Plugin starts but inspection never fires. No error is thrown. Changing annotation
strings or triggering the inspection produces no highlights.

Root cause: `<localInspection implementation="..."/>` is silently ignored.
The correct attribute is `implementationClass`:
```xml
<!-- WRONG — silently ignored -->
<localInspection implementation="com.example.MyInspection" .../>

<!-- CORRECT -->
<localInspection implementationClass="com.example.MyInspection" .../>
```

**Symptom 2 — Missing `shortName`:**
IDE throws at startup:
```
java.lang.IllegalArgumentException at buildCacheForKeyMapper
```
Root cause: `InspectionEP.getImplementationClassName()` returns null when `shortName`
is absent, and the cache builder does not handle null.

Fix: always provide `shortName` explicitly:
```xml
<localInspection
    language="JAVA"
    shortName="MyInspectionShortName"
    displayName="My inspection description"
    groupName="MyGroup"
    enabledByDefault="true"
    level="WARNING"
    implementationClass="com.example.MyInspection"/>
```

**Symptom 3 — Test registration:**
`myFixture.enableInspections(MyInspection.class)` throws "Unregistered inspection"
in `BasePlatformTestCase`. The class-based form requires the inspection to be
registered in a plugin.xml visible to the test sandbox.

Fix: use the instance-based form which bypasses the registry:
```java
myFixture.enableInspections(new MyInspection());
```

**Why non-obvious:**
All three issues produce either silent no-op or an unrelated-looking exception.
The IntelliJ SDK documentation shows `implementation` in some examples and
`implementationClass` in others — the inconsistency means developers copy the
wrong form. `shortName` is described as "optional" in the docs but crashes
without it in practice.

*Score: 13/15 · Included because: three distinct silent failures from one registration block, all underdocumented · Reservation: shortName crash may be version-specific*
