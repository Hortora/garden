# Garden Submission

**Date:** 2026-04-10
**Submission ID:** GE-0179
**Type:** technique
**Source project:** sparge
**Session context:** Unit-testing the PythonServer state machine without spawning a real Python process or mocking HTTP
**Suggested target:** `electron/electron-testing.md`

---

## Use an injectable `_pollFn` property to test Electron process managers without module mocking

**Stack:** Electron 33.x, Jest 29
**Labels:** `#testing`, `#pattern`

### Problem it solves

Testing a process manager class (like `PythonServer`) that calls `pollUntilReady()` internally. You want to test state machine transitions without waiting 15s for a real HTTP poll to time out.

### Why non-obvious

The natural approach is `jest.mock('../../python-server', factory)` with a module factory that replaces `pollUntilReady`. This has two failure modes: (1) the module factory must spread `jest.requireActual()` which requires careful setup; (2) the class still has a closure over the real `pollUntilReady` if it calls it as a module-level function, so the mock has no effect inside the class.

### The technique

Add `this._pollFn = pollUntilReady` in the constructor. The class calls `await this._pollFn(port)` instead of `await pollUntilReady(port)`. In tests, override it directly on the instance:

```javascript
// python-server.js
class PythonServer extends EventEmitter {
  constructor({ pythonExe, serverScript }) {
    super();
    // ...
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

### Benefits over module mocking

- No `jest.mock()` factory needed
- Works with fake timers without fighting closure semantics
- Integration tests just use the real `_pollFn` by default — no teardown needed
- The pattern signals intent: this function is intentionally injectable
