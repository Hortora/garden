**Submission ID:** GE-0079
**Date:** 2026-04-07
**Type:** gotcha
**Suggested target:** `intellij-platform/rename-refactoring.md` (new file, new dir)
**File header needed:** `# IntelliJ Platform — Rename Refactoring Gotchas and Techniques`

---

## PostprocessReformattingAspect Adds Spurious Space in Annotation Attributes After PSI Write

**Stack:** IntelliJ Platform (any version), `RenamePsiElementProcessor`

**Symptom:**
After a custom rename processor updates an annotation string attribute using `ElementManipulators.handleContentChange()` inside `renameElement()`, the result has a spurious space before the value:
```java
// Expected:
@Permute(className="Merge${i}")

// Actual:
@Permute(className= "Merge${i}")
```
The rename itself succeeds and the string value is correct — only the formatting is wrong. No error is thrown.

**Root cause:**
IntelliJ's `PostprocessReformattingAspect` runs after every PSI write action and normalises Java code style, including annotation attribute formatting. Calling `ElementManipulators.handleContentChange()` inside `renameElement()` (which runs inside a PSI write action) triggers the reformatter, which adds a space before the `=` separator in annotation attributes according to the active code style settings.

**Fix:**
Apply annotation string updates in `getPostRenameCallback()` using `Document.replaceString()` instead of `ElementManipulators.handleContentChange()` in `renameElement()`. The `getPostRenameCallback()` Runnable executes after the main rename write action completes, outside `PostprocessReformattingAspect`'s reach:

```java
@Override
public @Nullable Runnable getPostRenameCallback(
        @NotNull PsiElement element, @NotNull String newName,
        @NotNull RefactoringElementListener listener) {
    List<Pair<SmartPsiElementPointer<PsiLiteralExpression>, String>> updates = pendingUpdates.get();
    if (updates.isEmpty()) return null;

    Project project = element.getProject();
    return () -> {
        WriteCommandAction.runWriteCommandAction(project, () -> {
            PsiDocumentManager mgr = PsiDocumentManager.getInstance(project);
            for (Pair<SmartPsiElementPointer<PsiLiteralExpression>, String> update : updates) {
                PsiLiteralExpression lit = update.first.getElement();
                if (lit == null || !lit.isValid()) continue;
                Document doc = mgr.getDocument(lit.getContainingFile());
                if (doc == null) continue;
                mgr.doPostponedOperationsAndUnblockDocument(doc);
                TextRange range = ElementManipulators.getValueTextRange(lit)
                        .shiftRight(lit.getTextRange().getStartOffset());
                doc.replaceString(range.getStartOffset(), range.getEndOffset(), update.second);
            }
        });
        pendingUpdates.get().clear();
    };
}
```

**Why non-obvious:**
The `PostprocessReformattingAspect` runs transparently — there is no error, the attribute value is correct, and the issue only appears as a cosmetic formatting change. The connection between PSI write actions and the reformatter is not documented in the rename processor API. Developers naturally use `ElementManipulators.handleContentChange()` (the idiomatic PSI edit API) without knowing it triggers the reformatter.

*Score: 14/15 · Included because: silent wrong output, completely undocumented interaction, anyone building a rename processor will hit this · Reservation: none*
