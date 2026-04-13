# git Techniques

Non-obvious git capabilities worth knowing.

---


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
