# intellij-platform Index

| ID | Title | Type | Score |
|----|----|-------|-------|
| GE-0079 | PostprocessReformattingAspect Adds Spurious Space in Annotation Attributes After PSI Write | gotcha | 14/15 |
| GE-0080 | renamePsiElementProcessor Requires order="first" for getPostRenameCallback to Fire | gotcha | 14/15 |
| GE-0081 | Raw PsiElement References Collected in prepareRenaming() Are Invalidated by the Rename Write Action | gotcha | 13/15 |
| GE-0093 | FQN Resolution Inside FileBasedIndexExtension Causes Recursive Index Read and Crash | gotcha | 15/15 |
| GE-0110 | `localInspection` in plugin.xml Requires `implementationClass` and Explicit `shortName` | gotcha | 13/15 |
| GE-0111 | `intellij-platform-gradle-plugin` 2.x Auto-Sets `untilBuild` to `sinceBuild.*`, Blocking Newer IDEs | gotcha | 12/15 |
| GE-0112 | `SafeDeleteProcessorDelegate.shouldDeleteElement()` Removed in 2023.2 — Use `findConflicts()` | gotcha | 11/15 |
| GE-0116 | Custom `FileBasedIndexExtension` Not Populated After `addFileToProject()` in `BasePlatformTestCase` | gotcha | 14/15 |
| GE-0117 | `RenameHandler` Intercepts Before `RenamePsiElementProcessor.substituteElementToRename()` Is Called | gotcha | 12/15 |
| GE-0119 | PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated | technique | 12/15 |
| GE-0120 | `FindUsagesManager` Has a Public Constructor and Accepts `FindUsagesHandlerBase` Directly | undocumented | 11/15 |
| GE-0163 | `PsiParameter` does not extend `PsiMember` — use `getDeclarationScope()` to get the containing method | gotcha | 11/15 |
| GE-0164 | `Messages.showDialog()` auto-selects first option in IntelliJ headless test environment | gotcha | 12/15 |
| GE-0165 | IntelliJ MCP `ide_index_status` errors when multiple projects are open without `project_path` | gotcha | 12/15 |
| GE-20260416-74e114 | PsiAnnotation.getQualifiedName() returns bare simple name when import is unresolved — FQN checks silently miss | gotcha | 10/15 |
| GE-20260417-680e86 | IntelliJ MCP ide_diagnostics does not run LocalInspectionTool plugins — use get_file_problems instead | gotcha | 9/15 |
| GE-20260423-442a71 | IntelliJ flat-PSI annotator: element.getParent() != file guard is always false | gotcha | 12/15 |
| GE-20260423-70a4f2 | BasePlatformTestCase: <caret> inside injected language switches myFile to injected PsiFile | gotcha | 10/15 |
| GE-20260423-9a5470 | Testing IntelliJ Annotators on injected language: use doHighlighting() + HighlightInfo filter | technique | 9/15 |
| GE-20260423-af487b | IntelliJ MultiHostInjector: multiple addPlace() in one session concatenates content | undocumented | 11/15 |
| GE-20260423-e92da0 | IntelliJ 2023.2: testParameterInfo() absent — use MockCreateParameterInfoContext instead | undocumented | 9/15 |
| GE-20260602-c6bfb7 | IntelliJ Index MCP plugin port 29170 connection-refused while IDEA is running — transient JVM pause | gotcha | 11/15 |
| GE-20260604-a8ffaa | ide_find_class returns empty silently for classes in recently-added modules not yet PSI-indexed | gotcha | 8/15 |
| GE-20260614-3205f6 | Use ide_find_references at plan time to enumerate all callers before a method signature change | technique | 10/15 |
| GE-20260614-3205f6 | Use ide_find_references at plan time to enumerate all callers before a method signature change | technique | 10/15 |
| GE-20260627-fed7cf | ide_find_class misses protobuf-generated nested enums in large JAR classes — use ide_find_symbol as fallback | gotcha | 11/15 |
| GE-20260629-0a3cb4 | IntelliJ Index MCP plugin does not index TypeScript projects — all search and reference tools return empty | gotcha | 10/15 |
| GE-20260630-91be72 | IntelliJ MCP ide_refactor_rename partial failure — file not renamed, same-package refs missed, JPQL strings incorrectly updated | gotcha | 12/15 |
| GE-20260710-ddf617 | IntelliJ MCP ide_search_text misses strings split across Java string concatenation | gotcha | 9/15 |
| GE-20260713-69afbe | IntelliJ MCP structural editing (ide_edit_member, ide_replace_member, ide_insert_member) does not support TypeScript | gotcha | 10/15 |
| GE-20260714-13b430 | ide_insert_member reformat=true silently removes static imports | gotcha | 11/15 |
| GE-20260717-67af88 | ide_replace_text_in_file reduces \\ to \ in replacement text — breaks Java regex strings | gotcha | 10/15 |
| GE-20260718-b07bf8 | ide_optimize_imports does not add imports for symbols introduced by ide_replace_text_in_file in the same editing pass | gotcha | 11/15 |
| GE-20260718-c23bb5 | ide_replace_member duplicates method signature — inserts new body inside existing declaration | gotcha | 9/15 |
| GE-20260720-b6d2a8 | ide_replace_text_in_file silently returns 0 replacements when multi-line search text has whitespace mismatches | gotcha | 10/15 |
| GE-20260721-435df9 | IntelliJ MCP ide_create_file times out on large content (80+ lines) | gotcha | 9/15 |
| GE-20260723-fbbdb6 | IntelliJ Index MCP plugin operates on the wrong git repo when session runs in a git worktree | gotcha | 8/15 |
| GE-20260724-7ac683 | IntelliJ MCP ide_replace_text_in_file silently edits files in the wrong project when project_path points to a different worktree | gotcha | 13/15 |
