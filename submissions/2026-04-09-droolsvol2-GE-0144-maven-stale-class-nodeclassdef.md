**Submission ID:** GE-0144
**Date:** 2026-04-09
**Type:** gotcha
**Project:** drools-vol2 (cross-project — applies to any Maven build)
**Suggested target:** java/maven.md (existing file)

---

## Maven incremental build passes but `NoClassDefFoundError` at runtime — stale `.class` files

**Stack:** Maven (all versions)

**Symptom:**
`NoClassDefFoundError: org/example/MyClass` thrown at test runtime, even though `mvn compile` or `mvn test-compile` passed with no errors. The class clearly exists in source.

**Context:**
Encountered in Drools vol2 after changing `BetaNode` (adding a method override). Maven's incremental build recompiled `BetaNode.java` successfully. A dependent test class had a cached `.class` from before the change. At runtime, the JVM found the inconsistent old class file and failed.

**What was tried:**
- Checked pom.xml for missing dependencies (nothing missing)
- Checked classpath for duplicate jars (none)
- Re-ran `mvn compile` — passed clean, error persisted

**Root cause:**
Maven's incremental compilation only recompiles files whose source timestamps have changed. If a cached `.class` becomes structurally inconsistent with a newly compiled dependency (e.g. a method signature changed, a new abstract method was added), Maven doesn't detect or flag it. The old `.class` remains on disk and is loaded at runtime.

**Fix:**
```bash
mvn clean test
```
Forces full recompilation. Eliminates all stale class files. Use whenever tests throw `NoClassDefFoundError`, `ClassCastException`, or `AbstractMethodError` on classes that clearly exist in source.

**Why non-obvious:**
`NoClassDefFoundError` is universally diagnosed as a classpath/dependency problem — missing jar, wrong scope, shading conflict. The symptom gives no indication that the class exists on disk but is stale. Developers spend time inspecting `pom.xml` and dependency trees while the fix is `mvn clean`.

*Score: 11/15 · Included because: misleading symptom sends diagnosis in entirely the wrong direction · Reservation: `mvn clean` is a known fix, but the connection to incremental build staleness is non-obvious*

**IDs scanned for duplicates:** GE-0064, GE-0067 (java/maven.md entries — neither covers runtime class loading failures from stale incremental builds)
