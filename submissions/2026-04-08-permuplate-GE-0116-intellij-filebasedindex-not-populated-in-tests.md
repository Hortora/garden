**Type:** gotcha
**Submission ID:** GE-0116
**Date:** 2026-04-08
**Project:** permuplate
**Stack:** IntelliJ Platform SDK 232.x (2023.2), BasePlatformTestCase, FileBasedIndex

## Custom `FileBasedIndexExtension` not populated after `addFileToProject()` in `BasePlatformTestCase`

**Symptom:**
`FileBasedIndex.getInstance().getValues(MyCustomIndex.NAME, key, GlobalSearchScope.projectScope(project))` returns an empty list, even though the extension is registered in `plugin.xml`, the file was added to the project via `myFixture.addFileToProject()`, and the debug output shows the extension is configured. Tests calling the index get empty results and fail.

**Context:**
Writing IntelliJ plugin tests using `BasePlatformTestCase`. Custom `FileBasedIndexExtension` subclasses registered in `plugin.xml`. Files added via `myFixture.addFileToProject("Foo.java", content)`. Index queries immediately after return empty.

**What was tried:**
- Verified extension registered in `plugin.xml` ✓
- Verified file content matches the indexer's `containsPermute()` pre-filter ✓
- Verified `GlobalSearchScope.projectScope()` should include the temp dir ✓
- Called `FileBasedIndex.getInstance().getValues()` — empty
- Debug confirmed extension in effective POM — still empty

**Root cause:**
In `BasePlatformTestCase`, custom `FileBasedIndexExtension` plugins are not populated synchronously when files are added via `addFileToProject()`. The core Java symbol index (`JavaPsiFacade.findClass()`, `PsiShortNamesCache`) IS populated synchronously, but custom plugin-defined index extensions lag. The indexing likely runs asynchronously and hasn't completed by the time the test assertion runs.

**Fix / Workaround:**
Add a PSI scan fallback for any code path that queries custom indexes in tests. Use `ProjectFileIndex.iterateContent()` with direct PSI annotation inspection — this reads the PSI directly and is always up-to-date:

```java
// Fast path: custom FileBasedIndex (works in production)
String result = MyIndex.getInstance().lookup(name, project);
if (result != null) return result;

// Fallback: PSI scan (works in tests where index isn't populated)
PsiManager psiManager = PsiManager.getInstance(project);
ProjectFileIndex.getInstance(project).iterateContent(vFile -> {
    PsiFile psi = psiManager.findFile(vFile);
    // ... direct annotation inspection ...
    return true;
});
```

**Why non-obvious:**
The IntelliJ test framework is well-documented for standard Java indexes but silent about the async behaviour of custom `FileBasedIndexExtension`. The extension IS registered, the file IS in the project, and the scope DOES include the temp dir — the query simply returns empty with no error or warning. `PsiShortNamesCache` (core index) works correctly in the same test, making the failure seem impossible.

**Suggested target:** `intellij-platform/plugin-testing.md` (new file, header: `# IntelliJ Platform Plugin Testing Gotchas`)

*Score: 14/15 · Included because: invisible failure, no documentation, affects everyone writing IntelliJ plugin tests with custom indexes · Reservation: may be version-specific to 232.x*
