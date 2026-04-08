**Submission ID:** GE-0113
**Date:** 2026-04-08
**Project:** cc-praxis
**Type:** gotcha
**Stack:** GitHub CLI (`gh`), Claude Code `!` prefix, any non-interactive shell
**Suggested target:** `tools/github-cli.md` (existing)

---

## `gh auth refresh` requires an interactive terminal — the `!` prefix in Claude Code won't complete the OAuth flow

**Symptom:** Running `! gh auth refresh -h github.com -s project,read:project` in Claude Code either returns `--hostname required when not running interactively` or appears to succeed but the new scope is never applied — subsequent `gh` calls still fail with the missing scope error.

**Context:** Any attempt to add `gh` OAuth scopes from within a Claude Code session using the `!` command prefix.

### What was tried (didn't work)
- `! gh auth refresh -s project,read:project` — returned `--hostname required when not running interactively`
- `! gh auth refresh -h github.com -s project,read:project` — appeared to run but scope was not applied; `gh auth status` still showed old scopes
- Ran it twice — same result both times

### Root cause
`gh auth refresh` completes an OAuth device flow that requires a real PTY to open a browser tab and wait for user confirmation. The `!` prefix in Claude Code runs commands in a subprocess that doesn't have an interactive terminal attached — the OAuth flow cannot complete. The command exits without error but the scope is never granted.

### Fix
Run in a real terminal window outside Claude Code:
```bash
gh auth refresh -h github.com -s project,read:project
```
Then return to the Claude Code session — the new scope is picked up immediately by subsequent `gh` calls.

### Why non-obvious
The `!` prefix appears to work for most `gh` commands. There is no error message indicating the OAuth flow was skipped — the command exits 0. The failure only surfaces when the next `gh` call requiring the new scope still fails.

*Score: 10/15 · Included because: silent failure, no indication the scope wasn't granted, affects anyone adding gh scopes mid-session · Reservation: specific to interactive OAuth flows, not all gh commands*
