# Garden Submission

**Date:** 2026-04-10
**Submission ID:** GE-0180
**Type:** gotcha
**Source project:** sparge
**Session context:** Unit-testing PythonServer.killServer() with jest.useFakeTimers() — test hangs indefinitely
**Suggested target:** `javascript/jest-testing.md`

---

## `jest.useFakeTimers()` also fakes `setImmediate` — mock process exit events hang

**Stack:** Jest 29.x
**Symptom:** Test using `jest.useFakeTimers()` hangs indefinitely when a mock process's `.kill()` method uses `setImmediate(() => proc.emit('exit', ...))`. No timeout, no error — just never resolves.
**Context:** Testing Electron process manager state machine with fake timers to control backoff delays.

### What was tried (didn't work)

```javascript
proc.kill = jest.fn((signal) => setImmediate(() => proc.emit('exit', null, signal)));
// With jest.useFakeTimers() active, this never fires
```

The mock process kill is supposed to synchronously (next tick) emit the exit event, but under fake timers `setImmediate` is mocked and never executes unless explicitly advanced.

### Root cause

`jest.useFakeTimers()` replaces `setTimeout`, `setInterval`, `setImmediate`, and `clearImmediate` with fake implementations. `setImmediate` callbacks only run when you call `jest.runAllImmediates()` or `jest.advanceTimersByTime()`. A mock that uses `setImmediate` to defer an event emission will silently never fire.

### Fix

Use a microtask (`Promise.resolve().then(...)`) instead of `setImmediate`. Microtasks (Promise callbacks) are NOT affected by fake timers — they run on the real microtask queue:

```javascript
proc.kill = jest.fn((signal) => {
  Promise.resolve().then(() => proc.emit('exit', null, signal));
});
```

This fires immediately after the current synchronous code, before any timer callbacks, which is the correct semantics for a mock kill anyway.

### Alternative

If you need `setImmediate` specifically, use `jest.runAllImmediates()` after the operation:
```javascript
proc.kill('SIGTERM');
jest.runAllImmediates();
```
