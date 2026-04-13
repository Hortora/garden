# Markdown Techniques

Non-obvious ways to work with structured Markdown files efficiently.

---


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


---

## Title
**ID:** GE-XXXX — subtitle
```
The inserted content appears in the middle of the heading text. No error is raised; the corruption is only visible when reading the file.

**Context:** Any script that edits markdown headings programmatically using `str.replace()` with a partial match of the heading text, where the heading contains additional content after the matched prefix (e.g. `## Heading prefix — rest of title`).

### What was tried (didn't work)
```python
content = content.replace(
    '## Short heading prefix',
    '## Short heading prefix\n\n**ID:** GE-XXXX'
)
# If the actual heading is "## Short heading prefix — rest of title",
# the result is: "## Short heading prefix\n\n**ID:** GE-XXXX — rest of title"
# which renders as the heading split in two
```

### Root cause
`str.replace()` replaces the first occurrence of the literal string, regardless of what follows it. The replacement inserts after the matched prefix, splitting the original heading at that character position. The trailing ` — rest of title` becomes part of the next line.

### Fix
Match the complete heading line using regex with `$`:

```python
import re

# Match the full heading line (including any suffix after the prefix)
content = re.sub(
    r'(## Short heading prefix[^\n]*\n\n)',
    r'\1**ID:** GE-XXXX\n',
    content, count=1
)
```

`[^\n]*` captures everything to the end of the heading line. The replacement inserts after the full heading + blank line, before `**Stack:**`.

### Why non-obvious
The partial match looks correct in isolation — the prefix is right, and the replacement adds after it. The bug only appears when the heading contains more text after the matched prefix, which is invisible at the point of writing the replacement. Searching for the full heading text manually works; using the prefix in code fails silently.

*Score: 10/15 · Included because: silent corruption, non-obvious cause, common when scripting markdown edits · Reservation: fairly basic string-matching lesson, but the markdown-heading context makes it concrete*
