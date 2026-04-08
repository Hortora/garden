**Submission ID:** GE-0081
**Date:** 2026-04-07
**Type:** gotcha
**Suggested target:** `intellij-platform/rename-refactoring.md` (new file, new dir)
**File header needed:** `# IntelliJ Platform — Rename Refactoring Gotchas and Techniques`

---

## Raw PsiElement References Collected in prepareRenaming() Are Invalidated by the Rename Write Action

**Stack:** IntelliJ Platform (any version), `RenamePsiElementProcessor`

**Symptom:**
`PsiLiteralExpression` (or other `PsiElement`) instances collected during `prepareRenaming()` and stored in a `ThreadLocal` return `isValid() == false` or throw `NullPointerException` when accessed inside `getPostRenameCallback()` or `renameElement()`.

**Root cause:**
The rename write action modifies the PSI tree — it relocates, replaces, and rewrites nodes. Any raw `PsiElement` reference captured before the write action may point to a stale, invalidated node after it completes. IntelliJ provides `SmartPsiElementPointer` exactly for this scenario: it tracks the element through tree modifications and resolves to the post-modification node.

**Fix:**
Wrap all `PsiElement` references in `SmartPsiElementPointer` when storing them in `prepareRenaming()`:
```java
// In prepareRenaming():
SmartPointerManager spm = SmartPointerManager.getInstance(element.getProject());
SmartPsiElementPointer<PsiLiteralExpression> ptr = spm.createSmartPsiElementPointer(lit);
pendingUpdates.get().add(Pair.create(ptr, newValue));

// In getPostRenameCallback():
PsiLiteralExpression resolved = ptr.getElement();
if (resolved == null || !resolved.isValid()) continue; // element deleted during rename
// use resolved
```

**Why non-obvious:**
PSI invalidation during write actions is mentioned in the IntelliJ Platform docs, but the specific scenario (references captured in `prepareRenaming()` surviving into `getPostRenameCallback()`) is not documented. The failure mode — `isValid() == false` silently causing the update to be skipped, or NPE — looks like a logic bug rather than a lifecycle issue. `SmartPsiElementPointer` is the canonical solution but its necessity here is not surfaced by the API.

*Score: 13/15 · Included because: non-obvious lifecycle issue, silent failure or NPE, SmartPsiElementPointer necessity not documented for this scenario · Reservation: partial overlap with general "PSI element validity" guidance in docs*
