# Garden Submission

**Date:** 2026-04-09
**Submission ID:** GE-0137
**Type:** gotcha
**Source project:** hortora (soredium integration tests for concurrent git operations)
**Session context:** Writing integration tests for concurrent forage sessions pushing to a shared garden repo
**Suggested target:** `tools/git.md` (existing)

---

## `git push` to a Non-Bare Repo Is Rejected When the Target Branch Is Checked Out

**Stack:** Git (all versions)
**Symptom:** Integration tests simulating concurrent git push/pull between two clones fail with:
```
remote: error: refusing to update checked out branch: refs/heads/main
remote: error: By default, updating the current branch in a non-bare repository
remote: error: is denied, because it will make the index and work tree inconsistent
```
The push exits with a non-zero return code. The test fails even though the git operations themselves are correct.

**Context:** Integration tests that simulate two independent sessions both pushing to a shared "origin" repository. A common pattern is to `git init` a directory and clone it twice (clone A and clone B), expecting both clones to be able to push to the "origin". This fails because the origin has a working tree with `main` checked out.

### What was tried (didn't work)
```python
# Init a repo, clone it twice, have both push to origin
subprocess.run(["git", "clone", str(origin), str(session_a)])
subprocess.run(["git", "clone", str(origin), str(session_b)])

# Session A pushes successfully
git(session_a, "push", "origin", "main")  # ✅

# Session B pushes after A — rejected
git(session_b, "push", "origin", "main")  # ❌ "refusing to update checked out branch"
```

### Root cause
When you push to a non-bare repository, git refuses to update the branch that is currently checked out in the target's working tree. This prevents the working tree from becoming out of sync with the index. The restriction applies even if the working tree happens to be clean.

### Fix
Use `git init --bare` for the shared remote. Bare repositories have no working tree, so there is no checked-out branch — pushes from multiple clones are always accepted:

```python
# Create a bare repo as the shared remote
bare = root / "origin.git"
subprocess.run(["git", "init", "--bare", str(bare)])

# Seed it via a temporary clone
seed = root / "seed"
subprocess.run(["git", "clone", str(bare), str(seed)])
# ... make initial commit in seed ...
subprocess.run(["git", "-C", str(seed), "push", "-u", "origin", "main"])

# Both sessions clone from the bare remote
subprocess.run(["git", "clone", str(bare), str(session_a)])
subprocess.run(["git", "clone", str(bare), str(session_b)])

# Both can now push
git(session_a, "push", "origin", "main")  # ✅
git(session_b, "push", "origin", "main")  # ✅ (or conflict if diverged — expected)
```

### Why non-obvious
The error message says "refusing to update checked out branch" which sounds like a branch protection issue, not a bare vs non-bare distinction. Developers familiar with GitHub (which uses bare repos) never encounter this in normal work — it only surfaces in test environments where a local directory is used as the "remote". The fix (bare repo) is simple but requires knowing that "bare" is the right concept to reach for.

---

## Garden Score

| Dimension | Score (1–3) | Notes |
|-----------|-------------|-------|
| Non-obviousness | 3 | Error message misleads about root cause |
| Discoverability | 2 | In git docs but not prominent |
| Breadth | 2 | Affects anyone writing git integration tests |
| Pain / Impact | 2 | Tests fail; non-obvious fix |
| Longevity | 3 | Fundamental git behaviour — permanent |
| **Total** | **12/15** | |

**Case for inclusion:** Cross-project — affects anyone writing integration tests that simulate concurrent git push/pull. The error message actively misleads about root cause.
**Case against inclusion:** None identified.
