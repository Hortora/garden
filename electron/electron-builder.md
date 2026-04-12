# Electron Builder Gotchas

## electron-builder `extraResources` strips the source directory name — packed path omits the subdir

**ID:** GE-0173
**Stack:** electron-builder 25.x, Electron 33.x
**Symptom:** App crashes on launch when packaged — binary not found at expected path. No error during `npm run pack`. Works in dev mode.
**Context:** Bundling platform-specific runtimes via `extraResources` with `"to": "python"` targeting a source dir like `resources/python/mac-arm64/`.

**Root cause:** `extraResources` with `"from": "resources/python/mac-arm64", "to": "python"` copies the **contents** of `mac-arm64/` into `Resources/python/` — it does not create a `mac-arm64/` subdirectory. The platform subdir is stripped. `Resources/python/bin/python3` exists; `Resources/python/mac-arm64/bin/python3` does not.

**Fix:** In packaged mode, omit the platform subdir from the path:

```javascript
function getPythonExe() {
  const platform = process.platform;
  const arch     = process.arch;
  const dirMap   = { 'darwin-arm64': 'mac-arm64', 'darwin-x64': 'mac-x64' };
  const dir = dirMap[`${platform}-${arch}`];
  const exe = platform === 'win32' ? 'python.exe' : 'python3';
  if (app.isPackaged) {
    // electron-builder strips the platform subdir when copying extraResources
    return path.join(process.resourcesPath, 'python', 'bin', exe);
  }
  return path.join(__dirname, 'resources', 'python', dir, 'bin', exe);
}
```

**How to catch it earlier:** Inspect the output bundle after `npm run pack`:
```bash
find dist/ -name python3 -o -name python.exe | head -5
```

*Score: 11/15 · Non-obvious because the stripping only manifests in packaged mode; dev mode uses the unmodified source tree where the subdir exists · Reservation: electron-builder specific*

---
