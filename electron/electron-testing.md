# Electron Testing Gotchas and Techniques

## Electron E2E tests silently fail in git worktrees — binary and runtime missing

**ID:** GE-0176
**Stack:** Electron 33.x, electron-builder 25.x, git worktrees
**Symptom:** E2E tests time out with "waiting for event 'window'" — app never opens. No clear error about missing binary. Playwright just waits until timeout.
**Context:** Working in a git worktree created after running `npm install --ignore-scripts` to skip the `postinstall` hook.

**Root cause:** Two separate missing pieces:
1. **Electron binary not downloaded:** `npm install --ignore-scripts` skips Electron's `postinstall` hook which downloads the platform binary. Running `electron .` silently fails.
2. **Runtime not present:** Resources in `.gitignore` (e.g. embedded Python runtime) don't exist in a fresh worktree. The server fails to spawn, preventing the window from loading.

**Fix:** After `npm install --ignore-scripts` in a worktree:
```bash
# 1. Download Electron binary
node node_modules/electron/install.js

# 2. Make runtime available
# Option A: symlink from main worktree (fastest)
ln -s /path/to/main-repo/resources /path/to/worktree/resources
# Option B: re-download
node scripts/fetch-runtime.js
```

*Score: 11/15 · Symptom (timeout waiting for window) gives no indication of the root cause; requires knowing both the Electron postinstall hook and that gitignored resources don't cross worktrees · Reservation: worktree-specific setup issue*

---

## Use an injectable `_pollFn` property to test Electron process managers without module mocking

**ID:** GE-0179
**Stack:** Electron 33.x, Jest 29
**Labels:** `#testing` `#pattern`
**What it achieves:** Test state machine transitions in a process manager class without spawning real processes, waiting for real HTTP polls, or wrestling with Jest module factory semantics.

**Why non-obvious:** The natural approach is `jest.mock()` with a module factory. This has two failure modes: (1) the factory must spread `jest.requireActual()` which requires careful setup; (2) the class still holds a closure over the real function so the mock has no effect inside the class.

**The technique:** Add `this._pollFn = pollUntilReady` in the constructor. The class calls `await this._pollFn(port)` instead of the module-level function directly. In tests, override on the instance:

```javascript
// python-server.js
class PythonServer extends EventEmitter {
  constructor({ pythonExe, serverScript }) {
    super();
    this._pollFn = pollUntilReady; // injectable for tests
  }

  async spawnServer(port) {
    this._doSpawn();
    await this._pollFn(port);   // ← testable
    this._state = 'healthy';
  }
}
```

```javascript
// python-server.test.js
function makeServer() {
  const server   = new PythonServer({ pythonExe: 'python3', serverScript: 'server.py' });
  server._pollFn = jest.fn().mockResolvedValue(undefined); // inject mock
  return server;
}

test('reaches healthy state after spawnServer', async () => {
  spawn.mockReturnValue(makeMockProcess());
  const server = makeServer();
  await server.spawnServer(19001);
  expect(server._state).toBe('healthy');
});
```

**Benefits over module mocking:**
- No `jest.mock()` factory needed
- Works with fake timers without fighting closure semantics
- Integration tests use the real `_pollFn` by default — no teardown needed
- Signals intent: this function is intentionally injectable

*Score: 12/15 · Solves a real testing friction that skilled developers hit regularly; the closure/mock interaction failure mode is subtle and not documented · Reservation: requires discipline to keep `_pollFn` as the only call site*

---
