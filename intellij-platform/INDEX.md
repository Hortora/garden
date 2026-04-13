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
