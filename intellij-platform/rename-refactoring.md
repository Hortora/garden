# IntelliJ Platform — Rename Refactoring Gotchas and Techniques

Discovered building a custom `RenamePsiElementProcessor` for Permuplate template annotation renames.

---

## PostprocessReformattingAspect Adds Spurious Space in Annotation Attributes After PSI Write

**ID:** GE-0079
**Stack:** IntelliJ Platform (any version), `RenamePsiElementProcessor`
**Symptom:** After a custom rename processor updates an annotation string attribute using `ElementManipulators.handleContentChange()` inside `renameElement()`, the result has a spurious space before the value:
```java
// Expected:
@Permute(className="Merge${i}")

// Actual:
@Permute(className= "Merge${i}")
```
The rename itself succeeds and the string value is correct — only the formatting is wrong. No error is thrown.
**Context:** Any `RenamePsiElementProcessor` that updates annotation string attributes inside `renameElement()`.

### Root cause

IntelliJ's `PostprocessReformattingAspect` runs after every PSI write action and normalises Java code style, including annotation attribute formatting. Calling `ElementManipulators.handleContentChange()` inside `renameElement()` (which runs inside a PSI write action) triggers the reformatter, which adds a space before the `=` separator in annotation attributes according to the active code style settings.

### Fix

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

### Why non-obvious

The `PostprocessReformattingAspect` runs transparently — there is no error, the attribute value is correct, and the issue only appears as a cosmetic formatting change. The connection between PSI write actions and the reformatter is not documented in the rename processor API. Developers naturally use `ElementManipulators.handleContentChange()` (the idiomatic PSI edit API) without knowing it triggers the reformatter.

**See also:** GE-0080 (order="first" requirement — same rename processor pipeline), GE-0081 (PsiElement invalidation — same rename lifecycle)

*Score: 14/15 · Included because: silent wrong output, completely undocumented interaction, anyone building a rename processor will hit this · Reservation: none*

---

## renamePsiElementProcessor Requires order="first" for getPostRenameCallback to Fire

**ID:** GE-0080
**Stack:** IntelliJ Platform (any version), `plugin.xml` extension registration
**Symptom:** A custom `RenamePsiElementProcessor` is invoked — `prepareRenaming()` runs and `canProcessElement()` returns true — but `getPostRenameCallback()` never fires. The rename completes normally; no error is thrown. Custom post-rename logic is silently skipped.
**Context:** Any plugin registering a `RenamePsiElementProcessor` that relies on `getPostRenameCallback()`.

### Root cause

IntelliJ calls `getPostRenameCallback()` only on the "primary" processor — the one returned by `RenamePsiElementProcessor.forElement(element)`. This method iterates registered processors in registration order and returns the first whose `canProcessElement()` returns true. The bundled Java plugin registers a `JavaRenameRefactoringSupport` processor at default priority. Without explicit ordering, it wins the election and its `getPostRenameCallback()` (which returns null for most elements) runs instead of the custom processor's.

### Fix

Register with `order="first"` in `plugin.xml`:
```xml
<renamePsiElementProcessor
    implementation="com.example.MyRenameProcessor"
    order="first"/>
```

### Why non-obvious

`prepareRenaming()` is called on ALL processors whose `canProcessElement()` returns true — it appears the processor is working. Only `getPostRenameCallback()` (and `renameElement()` for the primary processor) is restricted to the primary. The distinction between "all processors" and "primary processor" is not documented in the `RenamePsiElementProcessor` Javadoc. The `order` attribute in `plugin.xml` is documented for some extension points but not called out as required here.

**See also:** GE-0079 (spurious space — same rename processor pipeline), GE-0081 (PsiElement invalidation — same rename lifecycle)

*Score: 14/15 · Included because: completely silent failure, 100% reproducible, anyone using getPostRenameCallback() will hit this · Reservation: none*

---

## Raw PsiElement References Collected in prepareRenaming() Are Invalidated by the Rename Write Action

**ID:** GE-0081
**Stack:** IntelliJ Platform (any version), `RenamePsiElementProcessor`
**Symptom:** `PsiLiteralExpression` (or other `PsiElement`) instances collected during `prepareRenaming()` and stored in a `ThreadLocal` return `isValid() == false` or throw `NullPointerException` when accessed inside `getPostRenameCallback()` or `renameElement()`.
**Context:** Any `RenamePsiElementProcessor` that captures `PsiElement` references in `prepareRenaming()` for use in callbacks.

### Root cause

The rename write action modifies the PSI tree — it relocates, replaces, and rewrites nodes. Any raw `PsiElement` reference captured before the write action may point to a stale, invalidated node after it completes. IntelliJ provides `SmartPsiElementPointer` exactly for this scenario: it tracks the element through tree modifications and resolves to the post-modification node.

### Fix

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

### Why non-obvious

PSI invalidation during write actions is mentioned in the IntelliJ Platform docs, but the specific scenario (references captured in `prepareRenaming()` surviving into `getPostRenameCallback()`) is not documented. The failure mode — `isValid() == false` silently causing the update to be skipped, or NPE — looks like a logic bug rather than a lifecycle issue. `SmartPsiElementPointer` is the canonical solution but its necessity here is not surfaced by the API.

**See also:** GE-0079 (spurious space — same rename processor pipeline), GE-0080 (order="first" requirement — same rename lifecycle)

*Score: 13/15 · Included because: non-obvious lifecycle issue, silent failure or NPE, SmartPsiElementPointer necessity not documented for this scenario · Reservation: partial overlap with general "PSI element validity" guidance in docs*
