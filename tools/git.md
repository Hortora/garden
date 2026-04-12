# git Techniques

Non-obvious git capabilities worth knowing.

---

## Git file history as a free per-file versioning system

**Stack:** git, bash
**Labels:** `#strategy` `#git` `#file-versioning` `#context-efficiency`
**What it achieves:** Access any previous version of a single file — content, diff, and age — without maintaining a separate archive. Works for any regularly committed file.
**Context:** Any file that evolves over time and gets committed (handover docs, config files, living indexes). Useful when you want "the version from last Tuesday" or "what changed since yesterday" without a changelog.

### The technique

```bash
# How many versions exist?
git log --oneline -- HANDOVER.md

# How old is the current version? (no file read required)
git log -1 --format="%ar" -- HANDOVER.md      # → "3 days ago"

# Read the previous version
git show HEAD~1:HANDOVER.md

# What changed between the last two versions?
git diff HEAD~1 HEAD -- HANDOVER.md

# Only the added/removed lines
git diff HEAD~1 HEAD -- HANDOVER.md | grep "^[+-]" | grep -v "^[+-][+-][+-]"

# Version from before a specific date
git log --before="2026-04-03" -1 --format="%H" -- HANDOVER.md \
  | xargs -I{} git show {}:HANDOVER.md

# Read one section from a previous version (combine with awk)
git show HEAD~1:HANDOVER.md | awk '/^## Open Questions/,/^---$/'
```

### Why this is non-obvious
Developers think of `git log` as commit history, not a file versioning API. The key insight: `git show <ref>:<path>` is a complete file read at any point in history — free, always available, no extra tooling.

The freshness check (`git log -1 --format="%ar"`) gives human-readable age without reading the file. Combined with `git diff`, you inspect what changed between versions by reading only the delta — not either full version.

### When to use it
- Replacing separate archive directories (no `docs/handovers/YYYY-MM-DD.md`)
- Checking freshness before deciding whether to load a file
- Auditing changes to configuration or living documents
- Surgical reads of previous versions combined with section extraction

---

## Use git -C <path> to operate on a repo without cd-ing into it

**ID:** GE-0002
**Stack:** Git (all versions supporting -C, which is 1.8.5+, effectively all versions in use)
**Labels:** `#git` `#multi-repo`
**What it achieves:** Runs any git command against a repository at a specified path without changing the shell's working directory.
**Context:** Any time you need to run git commands against multiple repositories in the same session, or when changing directory would be disruptive.

### The technique

```bash
# Check status of a repo that isn't your CWD
git -C ~/claude-workspace status --short

# View log of a different repo
git -C /path/to/other-repo log --oneline -5

# Add and commit in a repo elsewhere
git -C ~/claude-workspace add subdir/
git -C ~/claude-workspace commit -m "feat: add content"

# Push a different repo
git -C ~/claude-workspace push
```

The `-C <path>` flag tells git to change to that directory before running the command — but only for git, not for the shell. Your working directory is unchanged.

### Why this is non-obvious

The instinctive approach for multi-repo work is `cd repo1 && git commit && cd - && cd repo2 && git commit`. This is fragile (`cd -` only goes one level back), verbose, and breaks if any command fails partway through.

`git -C` is documented but not prominent — most developers learn git from tutorials that assume single-repo work and `cd` as the navigation primitive.

### When to use it
- Claude sessions that operate across multiple repos (a project repo + a shared workspace repo)
- CI scripts that need to run git commands against repos checked out at known paths
- Any time you want to avoid changing the shell's working directory mid-script

*Score: 8/15 · Included because: multi-repo workflows are common and the cd-based alternative is fragile; having it with multi-repo examples adds real value · Reservation: in the official git man page; findable with a web search*

---

## Use conventional commit scope as the primary feature-clustering signal over file paths

**ID:** GE-0043
**Stack:** Git (any version), conventional commits format
**Labels:** `#git` `#analysis` `#strategy`
**What it achieves:** Groups commits into feature-area clusters that match the author's own intent, producing far more meaningful issue groupings than file-path analysis — especially for repos where temporal signals are absent.
**Context:** When analysing a git history to group commits into features, epics, or tickets. Most applicable when the repo uses conventional commits (`feat(scope): description`).

### The technique

Extract the scope from the conventional commit subject line:

```python
import re
from collections import defaultdict

def extract_scope(subject: str) -> str | None:
    """Extract 'feat(garden): ...' → 'garden'. None if no scope."""
    m = re.match(r"^[a-z]+\(([^)]+)\):", subject)
    return m.group(1) if m else None

scope_clusters: dict[str | None, list] = defaultdict(list)
for commit in commits:
    scope_clusters[extract_scope(commit.subject)].append(commit)

# scope_clusters["garden"] → all feat/fix/docs(garden) commits together
# scope_clusters[None]     → commits with no scope → fall back to file path
```

Fall back to top-level directory for commits with no scope:

```python
def primary_area(subject: str, changed_files: list[str]) -> str:
    scope = extract_scope(subject)
    if scope:
        return scope
    if changed_files:
        return changed_files[0].split("/")[0]
    return "misc"
```

### Why this is non-obvious

The natural first instinct is to use file paths — "what did this commit touch?" — because file paths are always available. But top-level directories in many repos (`docs/`, `tests/`, `scripts/`) are cross-cutting infrastructure, not features. They dominate by volume but carry no feature signal.

The commit scope, by contrast, is the author explicitly labelling which feature they were working on. `feat(garden)` and `fix(garden)` both belong to the garden feature even if they touch different directories. The scope is the single strongest clustering signal available in conventional-commit repos.

Validated on a 279-commit repo: top-level dirs gave `docs` (114 hits), `tests` (83), `scripts` (48) — useless. Scopes gave `marketplace` (33), `garden` (12), `write-blog` (11) — exactly the feature areas.

### When to use it

- Grouping commits into features/epics for retrospective issue creation
- Building git history analysis tools (changelog generators, scope visualisers)
- Any workflow that needs to partition commits without reading diffs (faster, less API cost)
- Fallback to directory is safe for repos without consistent scoping

*Score: 12/15 · Included because: counter-intuitive that author-intent labels beat file-system signals; validated empirically on a real repo with before/after numbers · Reservation: only applies to repos using conventional commits*

---

## Use conventional commit scope to cluster commits into issues without reading per-commit diffs

**ID:** GE-0050
**Stack:** Git, conventional commits format (`type(scope): description`)
**Labels:** `#strategy` `#automation`
**What it achieves:** Accurately clusters hundreds of commits into logical feature groups from the one-line git log subject alone — no per-commit file diff needed.
**Context:** Retrospective issue mapping, changelog generation, release notes, any workflow that groups commits by feature area.

### The technique

```bash
# Get all commit subjects in one pass — no diff-tree needed
git log --no-merges --format="%H|%ad|%s" --date=short
```

Parse `type(scope): description` from the subject. The `scope` field is the primary grouping key:

```
feat(garden): add scoring system      → scope: garden
fix(garden): fix template heading     → scope: garden
feat(marketplace): add CLI install    → scope: marketplace
```

All commits sharing a scope belong together regardless of which files they touch. For repos with consistent conventional commits, 90%+ of commits are correctly grouped this way — without `git diff-tree --name-only <hash>` per commit.

**Related scope merging:** Look for scopes with a common prefix that represent facets of the same feature (`java-dev`, `java-code-review`, `java-git-commit` → one "Add Java skill suite" issue). The author's own scoping intent encodes the feature boundary.

**Fallback:** Use top-level directory of changed files (requires `git diff-tree`) for commits without scope.

### Why this is non-obvious

The reflex for "group commits by feature" is to look at changed files. The conventional commit scope already encodes the author's own grouping intent — it's a higher-quality signal than file paths because it reflects semantic intent, not mechanical file organisation. A refactor touching 20 files still has one scope; a bulk rename touching 50 files is still one commit with one scope.

*Score: 10/15 · Included because: reframe from "group by files touched" to "group by author's declared scope" is a genuine insight; saved significant work in a 285-commit retrospective · Reservation: only useful for repos with disciplined conventional commits*

**Note:** GE-0043 and GE-0050 are related techniques — GE-0043 covers the extraction pattern in detail; GE-0050 covers the no-diff-read approach for large-scale retrospective analysis.

---

## `git restore --staged .` Also Reverts Working Tree Changes

**ID:** GE-0118
**Stack:** Git (all versions)

**Symptom:** Running `git restore --staged .` to unstage files also reverts uncommitted working tree modifications to those files. Modified files you wanted to keep are silently reverted to their last committed state.

**Context:** Had a mix of staged file moves (git mv) and unstaged working tree modifications (e.g. pom.xml edits). Wanted to undo the staged moves but keep the unstaged changes. Ran `git restore --staged .` — the staged moves were unstaged, but the working tree modifications were also reverted.

### Root cause
`git restore --staged .` with a path spec (`.`) restores *both* the index (unstaging) *and* the working tree for files that have both staged and unstaged changes. The `--staged` flag alone doesn't protect the working tree when used with a broad path spec.

### Fix
To unstage specific files while preserving working tree changes, target files explicitly or use `git reset`:

```bash
# Unstage specific files only (safer)
git restore --staged path/to/specific/file.java

# Safest: reset only the index for specific files
git reset HEAD path/to/file.java

# If you need to unstage moves specifically:
git restore --staged src/old/path/File.java src/new/path/File.java
```

### Why non-obvious
`--staged` implies "only affect the staging area." The working tree revert behaviour is a surprise, especially when using `.` as the path spec. The git documentation mentions it but the mental model of `--staged` = "only the index" is intuitive and wrong.

*Score: 10/15 · Included because: `--staged` strongly implies index-only, working tree revert is silent · Reservation: arguably documented, though easy to miss*

---

## `git push` to a non-bare repo is rejected when the target branch is checked out

**ID:** GE-0137
**Stack:** Git (all versions)
**Symptom:** Integration tests simulating concurrent git push/pull between two clones fail with:

```
remote: error: refusing to update checked out branch: refs/heads/main
remote: error: By default, updating the current branch in a non-bare repository
remote: error: is denied, because it will make the index and work tree inconsistent
```

**Context:** Tests that `git init` a directory and clone it twice, expecting both clones to push to the "origin". Fails because the origin has a working tree with `main` checked out.

### What was tried (didn't work)
```python
# Init, clone twice, have both push to origin
subprocess.run(["git", "clone", str(origin), str(session_a)])
subprocess.run(["git", "clone", str(origin), str(session_b)])
git(session_a, "push", "origin", "main")  # ✅
git(session_b, "push", "origin", "main")  # ❌ "refusing to update checked out branch"
```

### Root cause
When you push to a non-bare repository, git refuses to update the branch currently checked out in the target's working tree. This prevents the working tree from becoming out of sync with the index. The restriction applies even if the working tree is clean.

### Fix
Use `git init --bare` for the shared remote. Bare repositories have no working tree, so there is no checked-out branch — pushes from multiple clones are always accepted:

```python
bare = root / "origin.git"
subprocess.run(["git", "init", "--bare", str(bare)])

# Seed via a temporary clone
seed = root / "seed"
subprocess.run(["git", "clone", str(bare), str(seed)])
# ... make initial commit in seed, push to bare ...

# Both sessions clone from the bare remote
subprocess.run(["git", "clone", str(bare), str(session_a)])
subprocess.run(["git", "clone", str(bare), str(session_b)])
git(session_a, "push", "origin", "main")  # ✅
git(session_b, "push", "origin", "main")  # ✅ (or conflict if diverged — expected)
```

### Why non-obvious
The error message says "refusing to update checked out branch" — sounds like branch protection, not a bare vs non-bare distinction. Developers familiar with GitHub (which uses bare repos internally) never encounter this in normal work. It only surfaces in test environments using a local directory as the "remote." The fix is simple but requires knowing "bare" is the right concept.

*Score: 12/15 · Included because: error message actively misleads, affects anyone writing git integration tests, bare repo concept not prominent in learning materials · Reservation: none*

---

## `git filter-branch --msg-filter` doubles footers already in commit bodies — two-pass required

**ID:** GE-0140
**Stack:** git (all versions)
**Symptom:** After running `git filter-branch --msg-filter` to append `Refs #6` footers to historical commits, some commits have the footer twice. Also: `filter-branch` may fail immediately with "Cannot rewrite branches: You have unstaged changes" before processing any commits.

### Root cause (doubled footers)
The `--msg-filter` script is applied unconditionally to every matched commit. If some commits already contain the footer (e.g. written by an earlier tool), the script appends a second copy with no awareness of existing content.

### Root cause (unstaged changes error)
`filter-branch` refuses to run if there are any uncommitted modifications in the working tree — even files unrelated to the commits being rewritten.

### Fix
Step 1 — stash before running:
```bash
git stash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter '...' -- HEAD
git stash pop
```

Step 2 — run a second deduplication pass with inline Python:
```bash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter '
python3 -c "
import sys, re
msg = sys.stdin.read()
lines = msg.split(chr(10))
seen = set()
result = []
for line in lines:
    m = re.match(r\"^(Refs|Closes)\s+(#\d+)\", line.strip())
    if m:
        key = line.strip()
        if key not in seen:
            seen.add(key)
            result.append(line)
    else:
        result.append(line)
output = chr(10).join(result)
output = re.sub(r\"\n{3,}\", chr(10)*2, output)
sys.stdout.write(output.rstrip(chr(10)) + chr(10))
"
' -- HEAD
```

### Why non-obvious
The filter is advertised as a message transformer — nothing in the documentation warns it has no knowledge of existing message content. The stash requirement is documented but easy to miss.

**See also:** GE-0141 (selective per-commit filter using `$GIT_COMMIT`)

*Score: 11/15 · Included because: non-obvious double-application behaviour, stash requirement not prominent, real pain when rewriting history in active repos · Reservation: moderately specific use case*

---

## Use `$GIT_COMMIT` in `--msg-filter` to selectively rewrite only specific commits by hash

**ID:** GE-0141
**Stack:** git (all versions)
**Labels:** `#git` `#history-rewriting`
**What it achieves:** Selectively amends specific commits by SHA while leaving all others unchanged — without a separate rebase step per commit.
**Context:** Retroactively adding issue references, co-author footers, or semantic prefixes to specific historical commits.

### The technique

The `--msg-filter` script has access to `$GIT_COMMIT` — the full SHA of the commit currently being rewritten. Use a `case` statement to target specific commits:

```bash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter '
case "$GIT_COMMIT" in
    abc123def456...)  cat && printf "\nCloses #1" ;;
    789xyz...)        cat && printf "\nRefs #6" ;;
    *)                cat ;;  # leave all other commits unchanged
esac
' -- HEAD
```

### Why this is non-obvious
`$GIT_COMMIT` is mentioned in the `git filter-branch` man page but its use in `--msg-filter` (vs other filters) is not documented with examples. Most developers assume `--msg-filter` processes all commits uniformly.

### When to use it
- Retroactively linking specific commits to issues without touching unrelated commits
- Adding footers selectively after inspecting which commits need them

**Important caveats:**
- Stash uncommitted changes before running (see GE-0140)
- Run with `FILTER_BRANCH_SQUELCH_WARNING=1` to suppress the deprecation warning
- Check commit bodies first — if some already have the footer, use GE-0140's deduplication pass
- `$GIT_COMMIT` uses the *original* SHA, not the rewritten one — pre-built case statements work correctly
- Force push required after rewriting: `git push --force-with-lease origin main`

**See also:** GE-0140 (doubled footers gotcha and deduplication pass)

*Score: 11/15 · Included because: not obvious from docs, saves significant manual rebasing, clean solution · Reservation: git filter-branch is deprecated (but still widely functional)*

---

## `git filter-branch` fails with staged changes — even for message-only rewrites

**ID:** GE-0174
**Stack:** git (all versions)
**Symptom:** `Cannot rewrite branches: Your index contains uncommitted changes.` — even when only modifying commit messages, not file contents.
**Context:** Running `git filter-branch --msg-filter '...' BASE..HEAD` while staged (but uncommitted) changes exist. The staged changes are unrelated to the commits being rewritten.

**Root cause:** `git filter-branch` requires a clean index regardless of which filter is used. Even `--msg-filter` (message-only) uses the same machinery and enforces the clean-index requirement. Staged changes trigger the error even if they have no bearing on the commits being rewritten.

**Fix:** Stash before running, pop afterwards:
```bash
git stash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --msg-filter 'your-script.sh' BASE..HEAD
git stash pop
```

**See also:** GE-0140 (doubled footers and the general stash workflow)

*Score: 10/15 · Included because: error message is misleading for message-only rewrites; staged-but-unrelated changes blocking is non-obvious · Reservation: covered as a secondary point in GE-0140; promoted here for discoverability*

---

## Merging a branch with `--delete-branch` auto-closes any PR targeting that branch

**ID:** GE-0175
**Stack:** GitHub (all versions)
**Symptom:** PR #B (targeting branch A) is silently closed — not retargeted — when branch A is merged and deleted. No warning, no retargeting prompt.
**Context:** Stacked PRs (B → A → main). Merging A with `--delete-branch` immediately closes B because its base branch no longer exists.

**Root cause:** GitHub closes PRs whose base branch is deleted rather than retargeting them — it cannot safely determine the new base. The PR must be manually recreated.

**Fix:**

Option 1 — Retarget before deleting:
```bash
gh pr merge A --merge          # no --delete-branch
gh pr edit B --base main
git push origin --delete A
```

Option 2 — Recreate after the fact:
```bash
gh pr create --base main --head B --title "..." --body "..."
```

**Prevention:** With stacked PRs, always retarget dependent PRs before deleting the base branch.

*Score: 11/15 · Non-obvious GitHub behaviour; error is silent with no warning · Reservation: GitHub-specific, may change if GitHub adds retargeting logic*

---

## Use `git filter-branch --msg-filter` with a Python hash→refs mapping to bulk-add commit footers

**ID:** GE-0178
**Stack:** git (all versions), Python 3
**Labels:** `#ci-cd` `#git`
**What it achieves:** Bulk-add or correct footers (e.g. `Refs #N`, `Closes #N`) on many historical commits in one pass. Handles 30+ commits where interactive rebase becomes unwieldy.

**Why non-obvious:** Most developers reach for `git rebase -i` and manually reword each commit. `--msg-filter` scales to any number of commits and is fully automatable — the script decides per-commit what to add.

**The technique:** Write a Python script that reads the old message from stdin, checks `$GIT_COMMIT` against a hash→refs mapping, and appends missing refs:

```python
#!/usr/bin/env python3
import sys, os

REFS = {
    'abc1234': ['Refs #42', 'Refs #43'],
    'def5678': ['Refs #41', 'Refs #40'],
}

msg    = sys.stdin.read()
commit = os.environ.get('GIT_COMMIT', '')
to_add = next((refs for h, refs in REFS.items() if commit.startswith(h)), [])
to_add = [r for r in to_add if r not in msg]   # skip if already present

if not to_add:
    sys.stdout.write(msg)
    sys.exit(0)

body = msg.rstrip() + '\n' + '\n'.join(to_add) + '\n'
sys.stdout.write(body)
```

Run it:
```bash
git stash    # index must be clean (see GE-0174)
FILTER_BRANCH_SQUELCH_WARNING=1 \
  git filter-branch --msg-filter 'python3 /tmp/fix_refs.py' BASE..HEAD
git stash pop
git push --force-with-lease origin BRANCH
```

**Safety net:** Create a backup tag before rewriting:
```bash
git tag backup-before-rewrite-$(date +%Y-%m-%d) HEAD
```

**See also:** GE-0141 (bash case statement approach for simpler cases), GE-0140 (deduplication pass if some commits already have the footer)

*Score: 11/15 · Included because: scalable approach a skilled developer wouldn't naturally reach for; skip-if-present guard prevents doubled footers · Reservation: filter-branch deprecated (but still widely functional)*

---
