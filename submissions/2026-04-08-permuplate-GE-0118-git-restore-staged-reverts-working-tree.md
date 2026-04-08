**Type:** gotcha
**Submission ID:** GE-0118
**Date:** 2026-04-08
**Project:** permuplate
**Stack:** Git (all versions)

## `git restore --staged .` also reverts working tree changes

**Symptom:**
Running `git restore --staged .` to unstage files also reverts uncommitted working tree modifications to those files. Modified files you wanted to keep are silently reverted to their last committed state.

**Context:**
Had a mix of staged file moves (git mv) and unstaged working tree modifications (pom.xml edits). Wanted to undo the staged moves but keep the pom.xml changes. Ran `git restore --staged .` — the staged moves were unstaged, but the pom.xml modifications were also reverted.

**Root cause:**
`git restore --staged .` with a path spec (`.`) restores *both* the index (unstaging) *and* the working tree for files that have both staged and unstaged changes. The `--staged` flag alone doesn't protect the working tree when used with a broad path spec.

**Fix:**
To unstage specific files while preserving working tree changes:
```bash
# Unstage specific files only (safer)
git restore --staged path/to/specific/file.java

# Or unstage everything but preserve working tree:
git restore --staged -- .   # same problem with broad spec

# Safest: reset only the index for specific files
git reset HEAD path/to/file.java

# If you need to unstage moves specifically:
git restore --staged src/old/path/File.java src/new/path/File.java
```

**Why non-obvious:**
`--staged` implies "only affect the staging area." The working tree revert behaviour is a surprise, especially when using `.` as the path spec. The git documentation mentions it but the mental model of `--staged` = "only the index" is intuitive and wrong.

**Suggested target:** `tools/git.md`

*Score: 10/15 · Included because: `--staged` strongly implies index-only, working tree revert is silent · Reservation: arguably documented, though easy to miss*
