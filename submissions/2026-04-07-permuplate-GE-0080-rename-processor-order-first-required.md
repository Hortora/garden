**Submission ID:** GE-0080
**Date:** 2026-04-07
**Type:** gotcha
**Suggested target:** `intellij-platform/rename-refactoring.md` (new file, new dir)
**File header needed:** `# IntelliJ Platform — Rename Refactoring Gotchas and Techniques`

---

## renamePsiElementProcessor Requires order="first" for getPostRenameCallback to Fire

**Stack:** IntelliJ Platform (any version), `plugin.xml` extension registration

**Symptom:**
A custom `RenamePsiElementProcessor` is invoked — `prepareRenaming()` runs and `canProcessElement()` returns true — but `getPostRenameCallback()` never fires. The rename completes normally; no error is thrown. Custom post-rename logic is silently skipped.

**Root cause:**
IntelliJ calls `getPostRenameCallback()` only on the "primary" processor — the one returned by `RenamePsiElementProcessor.forElement(element)`. This method iterates registered processors in registration order and returns the first whose `canProcessElement()` returns true. The bundled Java plugin registers a `JavaRenameRefactoringSupport` processor at default priority. Without explicit ordering, it wins the election and its `getPostRenameCallback()` (which returns null for most elements) runs instead of the custom processor's.

**Fix:**
Register with `order="first"` in `plugin.xml`:
```xml
<renamePsiElementProcessor
    implementation="com.example.MyRenameProcessor"
    order="first"/>
```
This ensures the custom processor wins `forElement()` and its `getPostRenameCallback()` is called.

**Why non-obvious:**
`prepareRenaming()` is called on ALL processors whose `canProcessElement()` returns true — it appears the processor is working. Only `getPostRenameCallback()` (and `renameElement()` for the primary processor) is restricted to the primary. The distinction between "all processors" and "primary processor" is not documented in the `RenamePsiElementProcessor` Javadoc. The `order` attribute in `plugin.xml` is documented for some extension points but not called out as required here.

*Score: 14/15 · Included because: completely silent failure, 100% reproducible, anyone using getPostRenameCallback() will hit this · Reservation: none*
