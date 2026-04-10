# Garden Submission

**Date:** 2026-04-10
**Submission ID:** GE-0173
**Type:** gotcha
**Source project:** sparge
**Session context:** Wrapping Sparge as an Electron desktop app with embedded CPython via python-build-standalone
**Suggested target:** `electron/electron-builder.md`

---

## electron-builder `extraResources` strips the source directory name — packed path omits the subdir

**Stack:** electron-builder 25.x, Electron 33.x
**Symptom:** App crashes on launch when packaged — Python binary not found at expected path. No error during `npm run pack`. Works perfectly in dev mode (`app.isPackaged === false`).
**Context:** When bundling platform-specific runtimes (e.g. `resources/python/mac-arm64/`) via `extraResources` with `"to": "python"`.

### What was tried (didn't work)

- Used `path.join(process.resourcesPath, 'python', 'mac-arm64', 'bin', 'python3')` in packaged mode — path does not exist inside the `.app` bundle
- Assumed the `to` field preserved the source directory structure

### Root cause

`extraResources` with `"from": "resources/python/mac-arm64", "to": "python"` copies the **contents** of `mac-arm64/` into `Resources/python/` — it does not create a `mac-arm64/` subdirectory inside `python/`. The platform subdir is stripped. So `Resources/python/bin/python3` exists but `Resources/python/mac-arm64/bin/python3` does not.

This only manifests in the packaged app. Dev mode uses the unmodified source tree where the subdir does exist.

### Fix

In packaged mode, omit the platform subdir from the path:

```javascript
function getPythonExe() {
  const platform = process.platform;
  const arch     = process.arch;
  const dirMap   = { 'darwin-arm64': 'mac-arm64', 'darwin-x64': 'mac-x64', ... };
  const dir = dirMap[`${platform}-${arch}`];
  const exe = platform === 'win32' ? 'python.exe' : 'python3';
  if (app.isPackaged) {
    // electron-builder strips the platform subdir when copying extraResources
    return path.join(process.resourcesPath, 'python', 'bin', exe);
  }
  return path.join(__dirname, 'resources', 'python', dir, 'bin', exe);
}
```

### How to catch it earlier

Run `npm run pack` and inspect the output bundle manually:
```bash
find dist/ -name python3 -o -name python.exe | head -5
```
The actual path will be obvious from the output.
