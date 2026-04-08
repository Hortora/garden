**Date:** 2026-04-09
**Submission ID:** GE-0122
**Type:** gotcha
**Title:** `package-private` members in `a.b.c` are inaccessible from `a.b` — sub-packages are distinct packages
**Stack:** Java (all versions)

## Symptom / Context
A class in package `io.quarkmind.plugin` cannot access `package-private` (default access) members of a class in `io.quarkmind.plugin.scouting`. Compilation fails with:

```
error: X has package-private access in io.quarkmind.plugin.scouting
```

The two packages share a common prefix and the developer expected them to share package-private scope, like directories sharing a parent folder.

## Root Cause
Java package scope is exact-match, not hierarchical. `io.quarkmind.plugin.scouting` is a completely separate package from `io.quarkmind.plugin`. There is no parent-child relationship at the access control level — the dotted naming is purely a naming convention, not an access hierarchy.

Package-private access (default, no modifier) means: accessible only from within the same package — the exact same fully-qualified package name. Sub-packages are not "inside" parent packages in any access-control sense.

This is specified in the Java Language Specification §6.6.1: "A member (class, interface, field, or method) of a reference type ... is accessible only if the package of the class or interface in which the member or constructor is declared is the same as the package of the class in which the member or constructor is being accessed."

## Fix / Technique
Four options, in order of preference:

1. **Make the member `public`** — if the member is genuinely part of the API, this is correct. Use `@VisibleForTesting` (Guava) or a doc comment to signal intent if it's public only for test access.

2. **Move the accessing class into the same package** — if `io.quarkmind.plugin.scouting` is the right package for both, move the caller there.

3. **Use `protected` + inheritance** — if the relationship is subclass-to-superclass, `protected` crosses package boundaries for subclasses.

4. **Java modules (`module-info.java`)** — JPMS allows `opens` directives for reflective access but does not change package-private compile-time visibility. Not a fix for this case.

```java
// package io.quarkmind.plugin.scouting
class ScoutingHelper {
    // package-private — accessible only from io.quarkmind.plugin.scouting
    void internalMethod() { ... }
}

// package io.quarkmind.plugin — CANNOT access internalMethod()
class PluginCoordinator {
    void run() {
        new ScoutingHelper().internalMethod(); // compile error
    }
}
```

Fix: either make `internalMethod()` public, or move `PluginCoordinator` to `io.quarkmind.plugin.scouting`.

## Why Non-Obvious
Developers familiar with filesystem directory hierarchies intuitively expect sub-packages to be "inside" parent packages — `plugin.scouting` feels like a sub-folder of `plugin`. The dotted naming reinforces this mental model. The Java Language Specification does not emphasise this distinction in introductory material, and most Java tutorials discuss access modifiers without explicitly calling out the non-hierarchical nature of packages. The mistake is common even among experienced Java developers who haven't been bitten by it before.

## Suggested target
`java/java-gotchas.md` (create if needed, header: `# Java Gotchas`)

*Score: 9/15 · Included because: moderately non-obvious; the filesystem-directory mental model is universally held and wrong; hits experienced developers too · Reservation: the fix is straightforward once identified; the JLS is authoritative but not widely read*
