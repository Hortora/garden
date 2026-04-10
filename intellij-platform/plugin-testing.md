# IntelliJ Platform Plugin Testing Gotchas

---

## Custom `FileBasedIndexExtension` Not Populated After `addFileToProject()` in `BasePlatformTestCase`

**ID:** GE-0116
**Stack:** IntelliJ Platform SDK 232.x (2023.2), BasePlatformTestCase, FileBasedIndex

**Symptom:** `FileBasedIndex.getInstance().getValues(MyCustomIndex.NAME, key, GlobalSearchScope.projectScope(project))` returns an empty list, even though the extension is registered in `plugin.xml`, the file was added to the project via `myFixture.addFileToProject()`, and the debug output shows the extension is configured. Tests calling the index get empty results and fail.

**Context:** Writing IntelliJ plugin tests using `BasePlatformTestCase`. Custom `FileBasedIndexExtension` subclasses registered in `plugin.xml`. Files added via `myFixture.addFileToProject("Foo.java", content)`. Index queries immediately after return empty.

### What was tried (didn't work)
- Verified extension registered in `plugin.xml` ✓
- Verified file content matches the indexer's pre-filter ✓
- Verified `GlobalSearchScope.projectScope()` should include the temp dir ✓
- Called `FileBasedIndex.getInstance().getValues()` — empty
- Debug confirmed extension in effective POM — still empty

### Root cause
In `BasePlatformTestCase`, custom `FileBasedIndexExtension` plugins are not populated synchronously when files are added via `addFileToProject()`. The core Java symbol index (`JavaPsiFacade.findClass()`, `PsiShortNamesCache`) IS populated synchronously, but custom plugin-defined index extensions lag. The indexing runs asynchronously and hasn't completed by the time the test assertion runs.

### Fix / Workaround
Add a PSI scan fallback for any code path that queries custom indexes in tests. Use `ProjectFileIndex.iterateContent()` with direct PSI annotation inspection — this reads the PSI directly and is always up-to-date. See GE-0119 for the full dual-path pattern.

### Why non-obvious
The IntelliJ test framework is well-documented for standard Java indexes but silent about the async behaviour of custom `FileBasedIndexExtension`. The extension IS registered, the file IS in the project, and the scope DOES include the temp dir — the query simply returns empty with no error or warning. `PsiShortNamesCache` (core index) works correctly in the same test, making the failure seem impossible.

*Score: 14/15 · Included because: invisible failure, no documentation, affects everyone writing IntelliJ plugin tests with custom indexes · Reservation: may be version-specific to 232.x*

**See also:** GE-0119 (PSI scan fallback pattern — technique for making custom index code testable)

---

## PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated

**ID:** GE-0119
**Stack:** IntelliJ Platform SDK 232.x, BasePlatformTestCase, FileBasedIndex
**Labels:** `#testing` `#pattern` `#intellij`
**What it achieves:** Makes IntelliJ plugin code work in both production (fast custom index) and `BasePlatformTestCase` tests (PSI direct scan fallback), without duplicating logic or adding test-specific branches.
**Context:** Any IntelliJ plugin with custom `FileBasedIndexExtension` that needs to be tested with `BasePlatformTestCase`, where the custom index isn't populated synchronously (see GE-0116).

### The technique
Structure index-dependent code with a fast path (custom `FileBasedIndex`) and a PSI scan fallback. The fallback uses `ProjectFileIndex.iterateContent()` + direct annotation inspection — always up-to-date because it reads live PSI, not the index.

```java
@Nullable
private static PsiClass findTemplateClass(String generatedName, Project project) {
    // Fast path: custom FileBasedIndex (O(1), works in production)
    String templateName = MyReverseIndex.getInstance().lookup(generatedName, project);
    if (templateName != null) {
        return findClassByName(templateName, project);
    }

    // Fallback: PSI scan (O(source files), works in tests where index isn't populated)
    PsiManager psiManager = PsiManager.getInstance(project);
    AtomicReference<PsiClass> found = new AtomicReference<>();

    ProjectFileIndex.getInstance(project).iterateContent(vFile -> {
        if (!vFile.getName().endsWith(".java")) return true;
        PsiFile psiFile = psiManager.findFile(vFile);
        if (!(psiFile instanceof PsiJavaFile javaFile)) return true;

        for (PsiClass cls : javaFile.getClasses()) {
            // Direct annotation inspection — no index required
            PsiAnnotation ann = findTargetAnnotation(cls);
            if (ann != null && generates(ann, generatedName)) {
                found.set(cls);
                return false; // stop iteration
            }
        }
        return true;
    });

    return found.get();
}
```

### Why this is non-obvious
Most developers would either (a) try to force the index to populate in tests (complex, fragile), or (b) mock the index (brittle, diverges from production). The dual-path approach is simple, tests real production logic paths, and degrades gracefully — in production the fallback is never reached; in tests it silently handles the index absence.

### When to use it
Any IntelliJ plugin with a custom `FileBasedIndexExtension` that queries the index as part of a real code path (not in a dedicated test for the index itself).

*Score: 12/15 · Included because: non-obvious solution, broadly applicable to any IntelliJ plugin with custom indexes, tests real code · Reservation: adds O(n) scan path*

**See also:** GE-0116 (root cause — why FileBasedIndex isn't populated in BasePlatformTestCase)

---

## `Messages.showDialog()` auto-selects first option in IntelliJ headless test environment

**ID:** GE-0164
**Stack:** IntelliJ Platform SDK (all versions), `BasePlatformTestCase`

**Symptom / Discovery:** Dialog-based plugin handlers (those calling `Messages.showDialog()`, `Messages.showYesNoDialog()`, etc.) appear untestable in the headless `BasePlatformTestCase` test environment — there is no UI to interact with.

**Context:** IntelliJ plugin tests run in a headless environment (no display). Any call to `Messages.showDialog()` would normally block waiting for user input.

### Root cause

`ApplicationManager.getApplication().isHeadlessEnvironment()` returns `true` in `BasePlatformTestCase` tests. In headless mode, `Messages` APIs do not show a dialog — they return the default option (index 0 = the first button) silently and immediately.

### Fix / Usage

To test a handler that calls `Messages.showDialog()`, invoke the handler directly and assert the behaviour that corresponds to option 0 being selected:

```java
// In test: Messages.showDialog() will auto-return 0 ("Go to Template")
// No mocking needed — just call invoke() and assert navigation side-effect
handler.invoke(project, editor, file, dataContext);
// assert navigation happened (option 0 = "Go to Template" was "clicked")
```

To test a different option, use `TestDialogManager.setTestDialog()` (available in recent IntelliJ Platform versions) to override the auto-selection:

```java
TestDialogManager.setTestDialog(message -> Messages.YES); // or any index
```

### Why non-obvious

The headless auto-selection behaviour is not documented in the IntelliJ Platform SDK. Developers assume dialog-invoking handlers are untestable in headless mode and accept them as permanent testing gaps. The actual behaviour (silent first-option selection) enables meaningful testing without any mocking.

*Score: 12/15 · Included because: directly changes what is considered testable, completely undocumented · Reservation: TestDialogManager API availability varies by platform version*

---
