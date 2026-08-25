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
| GE-20260610-eb673a | Claude Code Agent tool sub-agents do not inherit MCP server connections from the parent session | gotcha | 11/15 |
| GE-20260612-506191 | Claude Code settings.json env.PATH replaces the shell PATH entirely — does not prepend or merge | gotcha | 11/15 |
| GE-20260623-ec9c80 | Subagent Read tool on deleted-but-tracked files silently recreates them — undoing working-tree deletions | gotcha | 12/15 |
| GE-20260627-5f208a | Stale SDD report files from previous sessions mislead fresh subagents | gotcha | 10/15 |
| GE-20260717-886249 | IntelliJ MCP ide_create_file writes to VFS only — files invisible to Maven and filesystem until manual sync | gotcha | 9/15 |
| GE-20260803-032978 | Worktree-isolated agents cannot use IntelliJ MCP — worktree is not open in the IDE | gotcha | 9/15 |
| GE-20260803-ec5c8a | Parallel agent dispatch with worktree isolation for independent S-scale issues — cherry-pick merge pattern | technique | 10/15 |
| GE-20260804-caaf12 | IntelliJ MCP ide_replace_text_in_file treats \n in replaceText as literal backslash-n, not newlines | gotcha | 10/15 |
| GE-20260804-fe785f | IntelliJ MCP ide_insert_member does not support TypeScript — only Java and Kotlin | gotcha | 8/15 |
| GE-20260804-cf77dc | IntelliJ MCP workspace project_path routing — cross-module tools need parent path, per-file tools need submodule path | gotcha | 8/15 |
| GE-20260809-c99c70 | IntelliJ MCP ide_insert_member on dependency jar classes modifies PSI only — Maven cannot see the change | gotcha | 12/15 |
| GE-20260809-9a1ac2 | IntelliJ MCP ide_structural_search_replace cannot match diamond and explicit generics in one pattern | gotcha | 8/15 |
| GE-20260810-1e1d47 | IntelliJ MCP ide_edit_member class replacement doesn't update imports — reformat=true only removes, never adds | gotcha | 9/15 |
| GE-20260816-6eb6ff | IntelliJ MCP project loses Maven linkage when another session opens a workspace — dependency types invisible | gotcha | 9/15 |
| GE-20260816-7f35fb | design-review review.py --type spec is invalid — only accepts dimension types, not lifecycle types | gotcha | 8/15 |
| GE-20260820-b5877a | IntelliJ MCP ide_edit_member field replacement drops trailing semicolon | gotcha | 9/15 |
| GE-20260820-54a3a6 | IntelliJ MCP ide_replace_text_in_file matches cross-package fully-qualified names | gotcha | 8/15 |
| GE-20260820-f45988 | IntelliJ MCP slot clones register as duplicate project names — ide_* calls silently target wrong checkout | gotcha | 11/15 |
| GE-20260820-6fa118 | IntelliJ MCP indexes the checked-out branch only — classes from other branches are invisible even when commits exist in git | gotcha | 12/15 |
| GE-20260821-8ada11 | IntelliJ MCP ide_import_modules with duplicate Maven artifactIds — edits silently route to first-registered module | gotcha | 12/15 |
| GE-20260821-2b40cc | IntelliJ MCP ide_refactor_rename completes silently on timeout — operations succeed despite error response | gotcha | 10/15 |
| GE-20260822-a5d8f2 | IntelliJ SSR strips fully-qualified class names from constructor replacement patterns | gotcha | 9/15 |
| GE-20260822-150983 | Bulk Java record constructor extension via IntelliJ SSR | technique | 9/15 |
| GE-20260824-c6fbb4 | IntelliJ MCP ide_edit_member replaces entire class when member name matches class name | gotcha | 12/15 |
| GE-20260825-cd6efc | IntelliJ MCP ide_replace_text_in_file reports success but file on disk unchanged — VFS desync | gotcha | 10/15 |
| GE-20260825-ac5410 | IntelliJ MCP write operations time out while reads succeed — too many open projects | gotcha | 8/15 |
