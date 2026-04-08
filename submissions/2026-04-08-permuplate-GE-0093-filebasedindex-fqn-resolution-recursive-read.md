**Submission ID:** GE-0093
**Date:** 2026-04-08
**Type:** gotcha
**Suggested target:** `intellij-platform/indexing.md` (new file, new dir)
**File header needed:** `# IntelliJ Platform — Indexing Gotchas`

---

## FQN Resolution Inside FileBasedIndexExtension Causes Recursive Index Read and Crash

**Stack:** IntelliJ Platform (any version), `FileBasedIndexExtension`

**Symptom:**
Plugin throws repeatedly with:
```
com.intellij.diagnostic.PluginException: Failed to build index 'my.index.name'
  for file file:///path/to/SomeClass.java (file type = JAVA)
```
The crash occurs on arbitrary `.java` files across the project — not just files related to what the index is indexing. Error message gives no indication of the actual cause. The index is permanently broken until the plugin is uninstalled.

**Root cause:**
Inside a `FileBasedIndexExtension.DataIndexer`, calling any API that resolves an annotation class by fully-qualified name triggers reads from IntelliJ's stub index or symbol index. These are recursive index reads — reading an index from within an indexer — and IntelliJ throws a `StorageException` or `ProcessCanceledException`.

The two dangerous calls:
```java
// DANGEROUS — triggers FQN resolution → recursive index read
PsiModifierListOwner.getAnnotation("com.example.MyAnnotation");

// DANGEROUS — triggers FQN resolution → recursive index read
PsiAnnotation.getQualifiedName();
```

Both methods need to resolve the annotation class by its fully-qualified name, which requires reading the class index.

**Fix:**
Use `PsiAnnotation.getNameReferenceElement().getReferenceName()` to match annotations by simple name from the source text — no resolution, no index reads:

```java
// SAFE — reads source text only, no index access
private static @Nullable PsiAnnotation findAnnotation(PsiClass cls, String simpleName) {
    for (PsiAnnotation ann : cls.getAnnotations()) {
        PsiJavaCodeReferenceElement ref = ann.getNameReferenceElement();
        if (ref != null && simpleName.equals(ref.getReferenceName())) return ann;
    }
    return null;
}
```

Also add a cheap text pre-filter before touching PSI at all, to skip 99% of project files:

```java
@Override
public DataIndexer<K, V, FileContent> getIndexer() {
    return inputData -> {
        // Skip files that can't possibly match — avoids PSI entirely
        if (!inputData.getContentAsText().toString().contains("@MyAnnotation")) {
            return Collections.emptyMap();
        }
        PsiFile psiFile = inputData.getPsiFile(); // safe now
        ...
    };
}
```

Bump `getVersion()` after the fix to force IntelliJ to discard the corrupted index and rebuild:
```java
@Override public int getVersion() { return previousVersion + 1; }
```

**Why non-obvious:**
The IntelliJ SDK documentation for `FileBasedIndexExtension` does not warn that specific PSI API calls trigger index reads. The error message ("Failed to build index for SomeClass.java") suggests a problem with `SomeClass.java` specifically, obscuring that the bug is in the indexer itself. The crash occurs on random files (whichever happens to be indexed first), making it look non-deterministic. `getAnnotation(fqn)` and `getQualifiedName()` look completely innocuous — they are correct APIs in any other context.

*Score: 15/15 · Included because: completely silent at design time, misleading error at runtime, affects any plugin doing annotation-based indexing, fix requires non-obvious API substitution · Reservation: none*
