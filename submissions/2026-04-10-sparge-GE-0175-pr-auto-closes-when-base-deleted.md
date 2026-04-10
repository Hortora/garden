# Garden Submission

**Date:** 2026-04-10
**Submission ID:** GE-0175
**Type:** gotcha
**Source project:** sparge
**Session context:** Merging two stacked PRs — archive-room-redesign → main, then electron-wrapper → archive-room-redesign
**Suggested target:** `git/github-pr-workflow.md`

---

## Merging a branch with `--delete-branch` auto-closes any PR targeting that branch

**Stack:** GitHub (all versions)
**Symptom:** PR #B (targeting branch A) is silently closed — not just retargeted — when branch A is merged and deleted. No warning, no retargeting.
**Context:** When you have stacked PRs (B → A → main) and merge A with branch deletion enabled.

### What was tried (didn't work)

- Ran `gh pr merge A --merge --delete-branch` expecting GitHub to retarget B to main
- GitHub instead closed B immediately since its base no longer existed

### Root cause

GitHub closes PRs whose base branch is deleted, rather than retargeting them. This is by design — GitHub cannot safely determine what the new base should be. The PR must be manually recreated targeting the new base.

### Fix

Two options:

**Option 1:** Merge base PR without deleting the branch, retarget dependent PRs, then delete:
```bash
gh pr merge A --merge   # no --delete-branch
gh pr edit B --base main
git push origin --delete A
```

**Option 2:** Recreate the PR after the fact:
```bash
gh pr create --base main --head B --title "..." --body "..."
```

### Prevention

With stacked PRs, always retarget dependent PRs before deleting the base branch.
