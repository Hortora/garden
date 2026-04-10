# Garden Submission

**Date:** 2026-04-10
**Submission ID:** GE-0176
**Type:** gotcha
**Source project:** sparge
**Session context:** Running Electron E2E tests inside a git worktree created with npm install --ignore-scripts
**Suggested target:** `electron/electron-testing.md`

---

## Electron E2E tests silently fail in git worktrees — binary and runtime missing

**Stack:** Electron 33.x, electron-builder 25.x, git worktrees
**Symptom:** E2E tests time out with "waiting for event 'window'" — app never opens. No clear error about missing binary.
**Context:** Working in a git worktree created after running `npm install --ignore-scripts` to skip the `postinstall` hook.

### What was tried (didn't work)

- Running `npm run test:e2e` in worktree — timeout after 30s
- Checking for obvious errors — none; Playwright just times out waiting for the window

### Root cause

Two separate missing pieces:

1. **Electron binary not downloaded:** `npm install --ignore-scripts` skips Electron's `postinstall` hook which downloads the platform binary. Running `electron .` silently fails.

2. **Python runtime not present:** The embedded Python runtime (`resources/python/`) is in `.gitignore` and not committed, so it doesn't exist in a fresh worktree. The Sparge server fails to spawn, preventing the window from loading.

### Fix

After creating a worktree and running `npm install --ignore-scripts`:

```bash
# 1. Download Electron binary
node node_modules/electron/install.js

# 2. Make Python runtime available (two options):
# Option A: symlink from the main worktree (fastest)
ln -s /path/to/main-repo/resources /path/to/worktree/resources

# Option B: re-download (takes 1-3 min)
node scripts/fetch-python.js
```
