**Type:** gotcha
**Submission ID:** GE-0115
**Date:** 2026-04-08
**Project:** permuplate
**Stack:** Maven, maven-compiler-plugin 3.13.0, Java

## maven-compiler-plugin `<excludes>` doesn't prevent transitive compilation

**Symptom:**
Files listed in `<excludes>` still appear in compilation errors. The Maven debug output explicitly shows the file in the excludes list — `(f) excludes = [org/drools/core/SegmentMemory.java, ...]` — yet javac still compiles it and emits errors from inside it.

**Context:**
Trying to exclude WIP infrastructure files from a module's compilation because they depend on symbols not yet on the classpath. Added them to `<excludes>` in maven-compiler-plugin configuration. Debug confirmed the excludes were registered. Files still compiled.

**What was tried:**
- Added files to `<excludes>` individually by path — didn't work
- Added entire directories with `**` glob — didn't work
- Ran `mvn clean` to eliminate caching — didn't work

**Root cause:**
`maven-compiler-plugin <excludes>` only affects the *initial source file list* passed to javac. It removes the excluded files from the list of files javac is explicitly asked to compile. However, javac's own dependency resolution still pulls in any file referenced by an *included* file — if class A (included) imports class B (excluded), javac fetches and compiles B regardless. The plugin has no mechanism to prevent this.

**Fix / Workaround:**
Two options:
1. **Physically move files** out of the source root (e.g., to `src/main/java-wip/`) so javac cannot find them at all
2. **Remove all references** to the excluded files from included files first, then the excludes work as expected

```xml
<!-- This does NOT work when included files reference the excluded file -->
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <configuration>
    <excludes>
      <exclude>org/example/WipClass.java</exclude>
    </excludes>
  </configuration>
</plugin>
```

**Why non-obvious:**
The debug output explicitly confirms the exclude is configured correctly. There is no warning that the excluded file is being compiled anyway. The official documentation says nothing about this limitation. A developer would reasonably expect `<excludes>` to mean "don't compile this file" — not "don't include this in the initial list but still compile it if anything references it."

**Suggested target:** `tools/maven.md` (new file, header: `# Maven Gotchas and Techniques`)

*Score: 13/15 · Included because: completely non-obvious, debug output actively misleads, no documentation of the limitation · Reservation: none*
