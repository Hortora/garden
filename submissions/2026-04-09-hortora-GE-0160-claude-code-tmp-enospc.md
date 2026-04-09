---
title: "Claude Code /private/tmp fills during parallel subagents — ENOSPC on git commit despite free disk"
type: gotcha
domain: claude-code
score: 11
tags: [claude-code, subagents, disk, git, enospc]
verified: 2026-04-09
staleness_threshold: 365
summary: "Parallel subagent task output files fill /private/tmp independently of the root filesystem, causing ENOSPC on git commits even when df -h shows gigabytes free."
---

**Submission ID:** GE-0160
**Suggested target:** `claude-code/subagent-patterns.md`

## Symptom

A subagent git commit fails:
```
ENOSPC: no space left on device, open '/private/tmp/claude-501/...'
```
Running `df -h /` shows 28GB free on the root filesystem.

## Root Cause

Claude Code writes task output files to `/private/tmp/claude-501/` — a per-user temporary directory separate from the main filesystem. When running many parallel subagents, each one writes output to this directory. The temp directory fills independently of the root disk, triggering ENOSPC on any operation that tries to write there (including git, which writes to `/private/tmp` for lock files and pack operations).

## Fix

Run git commands from the main session using `dangerouslyDisableSandbox: true` instead of delegating them to subagents:

```bash
# In main session (not a subagent)
cd ~/the/repo && git add . && git commit -m "message"
# with dangerouslyDisableSandbox: true on the Bash tool call
```

The main session writes to a different path and does not share the subagent temp quota.

## Why Non-Obvious

`ENOSPC` on a git commit looks exactly like a full disk. `df -h /` shows plenty of space. Nothing in the error output references `/private/tmp` — the path appears only in a secondary error about the task output file, which is easy to miss. The actual disk and the problem disk are reported separately.
