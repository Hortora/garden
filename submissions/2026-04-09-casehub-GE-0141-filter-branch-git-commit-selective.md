**Type:** technique
**Submission ID:** GE-0141
**Date:** 2026-04-09
**Project:** casehub
**Stack:** git (all versions)
**Labels:** #git, #history-rewriting
**Scanned against:** no existing git techniques in index

## git filter-branch --msg-filter with $GIT_COMMIT for Selective Per-Commit Message Rewriting

**Technique:** The `--msg-filter` script in `git filter-branch` has access to the `$GIT_COMMIT` environment variable — the full SHA of the commit currently being rewritten. This enables a bash `case` statement to selectively amend specific commits by hash while leaving all others unchanged:

```bash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter '
case "$GIT_COMMIT" in
    abc123def456...)  cat && printf "\nCloses #1" ;;
    789xyz...)        cat && printf "\nRefs #6" ;;
    *)                cat ;;  # leave all other commits unchanged
esac
' -- HEAD
```

**When to use:** Retroactively adding issue references, co-author footers, semantic commit type prefixes, or any other footer to specific historical commits — without touching commits that already have the correct content or that should not be modified.

**Important caveats:**
- Stash uncommitted changes before running (filter-branch fails with "Cannot rewrite branches: You have unstaged changes")
- Run with `FILTER_BRANCH_SQUELCH_WARNING=1` to suppress the deprecation warning
- Check commit bodies first — if some already contain the footer, use a deduplication second pass (see GE-0140)
- Force push required after rewriting: `git push --force-with-lease origin main`
- `$GIT_COMMIT` uses the *original* commit hash, not the rewritten one — so a pre-built case statement using original SHAs works correctly even though the SHAs change after rewriting

**Why non-obvious:** The `$GIT_COMMIT` variable is mentioned in `git filter-branch` man page but its use in `--msg-filter` (vs other filters) is not documented with examples. Most developers assume `--msg-filter` processes all commits uniformly; the per-commit conditional pattern is rarely shown.

**Suggested target:** `tools/git.md`

*Score: 11/15 · Included because: not obvious from documentation, saves significant manual rebasing effort, clean solution to a common problem · Reservation: git filter-branch is deprecated (but still widely used and functional)*
