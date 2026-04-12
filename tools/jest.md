# Jest Gotchas

## `jest.useFakeTimers()` also fakes `setImmediate` — mock process exit events hang

**ID:** GE-0180
**Stack:** Jest 29.x
**Symptom:** Test using `jest.useFakeTimers()` hangs indefinitely when a mock process's `.kill()` uses `setImmediate(() => proc.emit('exit', ...))`. No timeout, no error — just never resolves.
**Context:** Testing an Electron process manager state machine with fake timers to control backoff delays.

**Root cause:** `jest.useFakeTimers()` replaces `setTimeout`, `setInterval`, `setImmediate`, and `clearImmediate` with fake implementations. `setImmediate` callbacks only run when you call `jest.runAllImmediates()` or `jest.advanceTimersByTime()`. A mock that uses `setImmediate` to defer an event emission will silently never fire.

**Fix:** Use a microtask (`Promise.resolve().then(...)`) instead of `setImmediate`. Microtasks (Promise callbacks) are NOT affected by fake timers — they run on the real microtask queue:

```javascript
// Instead of:
proc.kill = jest.fn((signal) => setImmediate(() => proc.emit('exit', null, signal)));

// Use:
proc.kill = jest.fn((signal) => {
  Promise.resolve().then(() => proc.emit('exit', null, signal));
});
```

**Alternative:** If `setImmediate` is needed specifically, advance it explicitly:
```javascript
proc.kill('SIGTERM');
jest.runAllImmediates();
```

*Score: 12/15 · Very non-obvious: `setImmediate` being faked by `jest.useFakeTimers()` is documented but easily missed; the resulting hang gives no error or indication of root cause · Reservation: Jest 29 specific; behaviour may differ in older versions*

---
