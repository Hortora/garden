**Submission ID:** GE-0112
**Date:** 2026-04-08
**Type:** gotcha
**Suggested target:** `intellij-platform/inspections.md` (or `intellij-platform/refactoring.md`)
**File header needed:** `# IntelliJ Platform — Refactoring Gotchas` (if separate file)

---

## `SafeDeleteProcessorDelegate.shouldDeleteElement()` Removed in 2023.2 — Use `findConflicts()`

**Stack:** IntelliJ Platform 2023.2+ (`SafeDeleteProcessorDelegate`)

**Symptom:**
Code written to block safe delete via `shouldDeleteElement()` does not compile
against IntelliJ 2023.2+:
```
error: cannot find symbol: method shouldDeleteElement(PsiElement)
```

Or: the delegate implementation compiles against the interface but the method
is never called at runtime — deletions proceed without any block.

**Root cause:**
`shouldDeleteElement(PsiElement)` was removed from `SafeDeleteProcessorDelegate`
in IntelliJ 2023.x. The replacement API is `findConflicts(PsiElement, PsiElement[])`,
which returns a `Collection<String>` of conflict messages shown in the Safe Delete
conflicts dialog. A non-empty collection blocks the deletion and shows the messages.

**Fix:**
Replace `shouldDeleteElement` with `findConflicts`:

```java
// OLD — does not exist in 2023.2+
@Override
public boolean shouldDeleteElement(@NotNull PsiElement element) {
    if (isGenerated(element)) return false; // block
    return true;
}

// NEW — works in 2023.2+
@Override
public Collection<String> findConflicts(
        @NotNull PsiElement element,
        PsiElement[] allElementsToDelete) {
    if (isGenerated(element)) {
        return List.of("This class is generated and will be recreated on next build.");
    }
    return Collections.emptyList(); // allow deletion
}
```

Also extend `SafeDeleteProcessorDelegateBase` (abstract class) rather than
implementing `SafeDeleteProcessorDelegate` (interface) directly — it provides
stub implementations of the overloaded `getElementsToSearch(element, module, all)`
variant, which has a different signature in different platform versions.

**Why non-obvious:**
The removal is not documented in IntelliJ's migration guides. The interface compiles
cleanly (the method simply no longer exists to override), and there is no deprecation
warning pointing to `findConflicts`. Searching the SDK docs for "safe delete block"
returns examples using the old API.

*Score: 11/15 · Included because: API removed without migration path in docs, silent runtime failure if using old pattern · Reservation: affects niche use case (custom safe delete)*
