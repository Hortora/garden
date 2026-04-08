**Date:** 2026-04-09
**Submission ID:** GE-0121
**Type:** gotcha
**Title:** `mv` project folder invalidates Bash tool's shell cwd mid-session
**Stack:** Claude Code Bash tool, macOS shell

## Symptom / Context
After renaming a project folder with `mv /old /new`, all subsequent Bash tool calls fail with "Working directory '/old' no longer exists. Please restart Claude from an existing directory." even when using absolute paths in the command. The shell is completely unusable for the remainder of the session.

## Root Cause
The Bash tool's shell process was started with cwd set to the old folder path. When the folder is renamed, the shell's cwd inode becomes invalid. The shell process cannot recover — it fails on startup for each subsequent call. The error message suggests restarting Claude rather than pointing to the folder rename as the cause.

Compounding this: the `Read`, `Write`, `Edit`, and `Glob` tools do NOT use the shell's cwd and continue to work after the rename, since they use the absolute paths passed to them directly.

## Fix / Technique
Three mitigations:

1. **Do the rename last** — if you know a folder rename is needed, make it the absolute final operation in the session after all other work is complete.

2. **Use non-shell tools after the rename** — `Read`, `Write`, `Edit` work via absolute path and are unaffected. For file content operations, they can substitute for many bash commands.

3. **Use the IntelliJ MCP `execute_terminal_command` tool** — this spawns a fresh process with its own working directory and bypasses the broken shell state. It has limitations (some commands time out) but can run simple file operations:
   ```
   mcp__intellij__execute_terminal_command: ls /absolute/path/
   ```

For a new agentic session, start from an existing directory (e.g., the renamed path) and the shell initialises correctly.

## Why Non-Obvious
`mv` succeeds silently (exit 0), so there is no error at rename time. The failure only appears on the next unrelated bash command, with an error message that suggests restarting Claude rather than pointing to the rename as the cause. Developers will try re-running the failed command with explicit absolute paths (which should work) and be confused when it still fails — because the problem is not the command, it is the shell process itself.

Additionally, the fact that `Read`/`Write`/`Edit` tools continue working masks the issue: some operations succeed, some fail, with no obvious pattern unless you know about the cwd dependency.

## Suggested target
`tools/claude-code.md` (file exists, header: `# Claude Code Gotchas and Techniques`)

*Score: 11/15 · Included because: non-obvious symptom that blames Claude restart rather than the rename; affects the whole session; cross-project whenever a folder is renamed mid-session · Reservation: only hits when you rename a folder in an agentic session, which is uncommon — but painful when it does*
