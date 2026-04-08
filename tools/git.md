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
