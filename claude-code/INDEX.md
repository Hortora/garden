# claude-code Index

| ID | Title | Type | Score |
|----|----|-------|-------|
| GE-0001 | Claude Code settings.json rejects unknown top-level fields despite additionalProperties schema | gotcha | 12/15 |
| GE-0160 | Claude Code `/private/tmp` fills during parallel subagents — ENOSPC on git commit despite free disk | gotcha | 11/15 |
| GE-20260413-8cb955 | Claude Code hook silently backgrounds all Bash calls regardless of run_in_background flag | gotcha | 13/15 |
| GE-20260414-6b964c | Two separate subagents for spec compliance then code quality catch different issues than one combined reviewer | technique | 10/15 |
| GE-20260414-b12a99 | Background subagent blocks on Bash leaves file edits uncommitted in worktree | gotcha | 10/15 |
| GE-20260417-15f33f | AI session handover can describe committed work that was never committed | gotcha | 9/15 |
| GE-20260422-3254e2 | Project-local .claude/settings.json creates an isolated Claude Code agent context with pre-approved commands | undocumented | 12/15 |
| GE-20260422-e72442 | --dangerously-skip-permissions bypasses the entire Claude Code permission system, including the deny list | gotcha | 11/15 |
| GE-20260504-9c9b01 | Claude Code permission allowlist does not suppress the 'Contains expansion' shell safety prompt | undocumented | 11/15 |
| GE-20260513-2239f6 | Claude Code Edit tool refuses to write through symlink paths — use readlink -f first | gotcha | 10/15 |
| GE-20260525-58fcbf | Always-needed vs triggered: decision rule for AI context file curation | technique | 9/15 |
| GE-20260525-3fe619 | wc -l understates AI context file bloat — always measure with wc -c | gotcha | 8/15 |
| GE-20260525-6c3a27 | gh issue close --comment with backtick-quoted text adds spurious bash permission entries to settings.local.json | gotcha | 10/15 |
| GE-20260526-b28228 | Multi-repo Claude sessions load all ancestor CLAUDE.md files — parent Workspace declaration shadows the active session's | gotcha | 10/15 |
| GE-20260605-248ca7 | Design parallel agents as write-only — pass all deletions back to the parent session | technique | 9/15 |
