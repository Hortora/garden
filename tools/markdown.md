# Markdown Techniques

Non-obvious ways to work with structured Markdown files efficiently.

---

## `awk '/^## title/,/^---$/'` extracts exactly one section without loading the whole file

**Stack:** awk, Markdown, bash
**Labels:** `#pattern` `#awk` `#context-efficiency`
**What it achieves:** Reads from a `##` heading to the next `---` separator — giving you exactly one entry from a structured Markdown file, regardless of file size.
**Context:** Markdown files where entries are separated by `---` and each starts with a `##` heading. Common in knowledge bases, changelogs, and diary-style files.

### The technique

```bash
# Extract the entry titled "GCD main queue blocks silently"
awk '/^## GCD main queue/,/^---$/' macos-native-appkit/appkit-panama-ffm.md

# Partial title match works too
awk '/^## Arena.ofAuto/,/^---$/' java-panama-ffm/native-image-patterns.md

# Combine with grep for flexible matching
awk '/^## .*dispatch_async.*/,/^---$/' macos-native-appkit/appkit-panama-ffm.md

# Read one section from a previous git version
git show HEAD~1:HANDOVER.md | awk '/^## Open Questions/,/^---$/'
```

The awk range pattern `start,end` reads all lines from the first match of `start` to the first match of `end`. Once `---` is found, awk stops — so only one entry is returned regardless of how many follow.

### Why this is non-obvious
Most developers reach for:
- `grep -A 40 "## title" file` — requires guessing `-A N`; cuts off if entry is longer
- `sed -n '/## title/,/^---$/p' file` — equivalent but less readable
- Loading the whole file — simple but wastes context (especially in LLM context windows)

The awk range pattern is self-terminating: reads until `---` and stops regardless of entry length. No line-count guessing.

### When to use it
- Large structured Markdown files where you need one section
- Knowledge bases, garden files, changelogs with `---`-separated entries
- LLM context windows where loading the full file would be wasteful
- Compose with `grep` for fuzzy title matching, with `git show` for file history
