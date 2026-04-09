**Type:** undocumented
**Submission ID:** GE-0147
**Date:** 2026-04-09
**Project:** permuplate (IntelliJ plugin)

## `Messages.showDialog()` Auto-Selects First Option in IntelliJ Headless Test Environment

**Stack:** IntelliJ Platform SDK (all versions), `BasePlatformTestCase`

**Symptom / Discovery:**
Dialog-based plugin handlers (those calling `Messages.showDialog()`, `Messages.showYesNoDialog()`, etc.) appear untestable in the headless `BasePlatformTestCase` test environment — there is no UI to interact with.

**Context:**
IntelliJ plugin tests run in a headless environment (no display). Any call to `Messages.showDialog()` would normally block waiting for user input. Instead, in headless mode, the platform automatically selects the first option (index 0) and returns immediately.

**Root cause / Behaviour:**
`ApplicationManager.getApplication().isHeadlessEnvironment()` returns `true` in `BasePlatformTestCase` tests. In headless mode, `Messages` APIs do not show a dialog — they return the default option (index 0 = the first button) silently and immediately.

**Fix / Usage:**
To test a handler that calls `Messages.showDialog()`, invoke the handler directly and assert the behaviour that corresponds to option 0 being selected:

```java
// In test: Messages.showDialog() will auto-return 0 ("Go to Template")
// No mocking needed — just call invoke() and assert navigation side-effect
handler.invoke(project, editor, file, dataContext);
// assert navigation happened (option 0 = "Go to Template" was "clicked")
```

To test a different option, you can use `TestDialogManager.setTestDialog()` (available in recent IntelliJ Platform versions) to override the auto-selection:

```java
TestDialogManager.setTestDialog(message -> Messages.YES); // or any index
```

**Why non-obvious:**
The headless auto-selection behaviour is not documented in the IntelliJ Platform SDK. Developers assume dialog-invoking handlers are untestable in headless mode and accept them as permanent testing gaps. The actual behaviour (silent first-option selection) enables meaningful testing without any mocking.

**Suggested target:** `intellij-platform/plugin-testing.md`

*Score: 12/15 · Included because: directly changes what is considered testable, completely undocumented · Reservation: TestDialogManager API availability varies by platform version*
