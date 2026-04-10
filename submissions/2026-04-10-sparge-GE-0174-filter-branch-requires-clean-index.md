# Garden Submission

**Date:** 2026-04-10
**Submission ID:** GE-0174
**Type:** gotcha
**Source project:** sparge
**Session context:** Bulk-rewriting commit message footers across ~30 commits using git filter-branch --msg-filter
**Suggested target:** `git/git-history-rewriting.md`

---

## `git filter-branch` fails with staged changes — even for message-only rewrites

**Stack:** git (all versions)
**Symptom:** `Cannot rewrite branches: Your index contains uncommitted changes.` — even when you only want to modify commit messages, not file contents.
**Context:** Running `git filter-branch --msg-filter '...' BASE..HEAD` while working files are staged.

### What was tried (didn't work)

- Running filter-branch with staged (but uncommitted) changes — blocked with the error above
- The staged changes were unrelated to the commits being rewritten

### Root cause

`git filter-branch` rewrites the entire history between the specified range, which requires a clean index to safely switch between commits. Even `--msg-filter` (which only modifies commit messages) uses the same machinery and enforces the clean-index requirement.

### Fix

Stash staged changes before running filter-branch, then pop afterwards:

```bash
git stash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --msg-filter 'your-script.sh' BASE..HEAD
git stash pop
```

Note: `FILTER_BRANCH_SQUELCH_WARNING=1` suppresses the deprecation warning suggesting `git-filter-repo` instead.
