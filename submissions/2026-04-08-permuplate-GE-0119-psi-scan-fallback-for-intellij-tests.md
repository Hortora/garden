**Type:** technique
**Submission ID:** GE-0119
**Date:** 2026-04-08
**Project:** permuplate
**Stack:** IntelliJ Platform SDK 232.x, BasePlatformTestCase, FileBasedIndex
**Labels:** #testing #pattern #intellij

## PSI scan fallback for IntelliJ plugin tests when custom FileBasedIndex isn't populated

**What it achieves:**
Makes IntelliJ plugin code work in both production (fast custom index) and `BasePlatformTestCase` tests (PSI direct scan fallback), without duplicating logic or adding test-specific branches.

**The technique:**
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

**Why non-obvious:**
Most developers would either (a) try to force the index to populate in tests (complex, fragile), or (b) mock the index (brittle, diverges from production). The dual-path approach is simple, tests real production logic paths, and degrades gracefully — in production the fallback is never reached; in tests it silently handles the index absence.

This pattern was used in `substituteElementToRename()` and `collectFamilySiblings()` in the Permuplate IntelliJ plugin to make both paths testable without mocking.

**Suggested target:** `intellij-platform/plugin-testing.md`

*Score: 12/15 · Included because: non-obvious solution, broadly applicable to any IntelliJ plugin with custom indexes, tests real code · Reservation: adds O(n) scan path*
