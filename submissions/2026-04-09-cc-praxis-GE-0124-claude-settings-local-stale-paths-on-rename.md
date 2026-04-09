---
type: gotcha
project: cc-praxis
date: 2026-04-09
---

## Renaming a Claude Code project directory leaves stale absolute paths in `.claude/settings.local.json`

**Submission ID:** GE-0124
**Stack:** Claude Code (any version), macOS/Linux
**Symptom:** After renaming a project directory (e.g. `mv ~/claude/skills ~/claude/cc-praxis`), previously granted permissions silently fail or behave unexpectedly. A ghost directory (`~/claude/oldname/.claude/`) may also appear containing a near-duplicate of the original `settings.local.json`.

**Context:** Any Claude Code project that accumulates granted permissions over time and is later renamed or moved.

### What was tried (didn't work)
- `mv ~/claude/skills ~/claude/cc-praxis` — the directory renamed correctly but permissions referencing the old absolute path remained broken
- Assuming `mv` would handle everything — it moves bytes but not content strings

### Root cause
`settings.local.json` accumulates absolute path permission entries over time (every `Bash(...)`, `Read(...)` etc. approval gets recorded). `mv` renames the directory but does not update the string contents of files. All permissions containing the old path (e.g. `Read(//Users/mdproctor/claude/skills/**)`) silently no longer match the new location. Additionally, a ghost `~/claude/oldname/.claude/` directory can appear after the rename — likely recreated by Claude Code or a session-start hook attempting to access the old path.

### Fix
After renaming, update all path references in the new location's `settings.local.json`:

```bash
sed -i '' 's|/Users/mdproctor/claude/skills/|/Users/mdproctor/claude/cc-praxis/|g' \
  ~/claude/cc-praxis/.claude/settings.local.json

# Verify no old paths remain (excluding ~/.claude/skills/ which is the install dir)
grep "claude/skills/" ~/claude/cc-praxis/.claude/settings.local.json
```

Then remove the ghost directory if it appeared:
```bash
rm -rf ~/claude/oldname/
```

### Why non-obvious
`mv` is a well-understood command — developers assume it handles a rename completely. Nothing warns you that file *contents* still reference old paths. Permissions fail silently (the tool just isn't granted rather than throwing an error), making it hard to connect the symptom to the rename. The ghost directory appearing post-rename adds confusion about whether the rename succeeded at all.

*Score: 12/15 · Included because: silent failure, cross-project (any Claude Code rename), fix requires knowing to look inside settings.local.json · Reservation: somewhat specific to Claude Code's permission accumulation model*

**Suggested target:** `tools/claude-code.md`
