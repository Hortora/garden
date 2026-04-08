**Submission ID:** GE-0107
**Date:** 2026-04-08
**Project:** cc-praxis (garden MERGE — assigning IDs to existing entries)
**Type:** gotcha
**Stack:** Python (any version), `str.replace()` or `str.split()`, any markdown file editing script
**Suggested target:** `tools/markdown.md` (existing)

---

## Partial heading match in `str.replace()` corrupts markdown headings when the matched prefix is followed by more text

**Symptom:** After running a script that inserts content after a markdown heading, the heading is split mid-line. A heading like `## Title — subtitle` becomes:
```
## Title
**ID:** GE-0042 — subtitle
```
The inserted content appears in the middle of the heading text. No error is raised; the corruption is only visible when reading the file.

**Context:** Any script that edits markdown headings programmatically using `str.replace()` with a partial match of the heading text, where the heading contains additional content after the matched prefix (e.g. `## Heading prefix — rest of title`).

### What was tried (didn't work)
```python
content = content.replace(
    '## Short heading prefix',
    '## Short heading prefix\n\n**ID:** GE-0042'
)
# If the actual heading is "## Short heading prefix — rest of title",
# the result is: "## Short heading prefix\n\n**ID:** GE-0042 — rest of title"
# which renders as the heading split in two
```

### Root cause
`str.replace()` replaces the first occurrence of the literal string, regardless of what follows it. The replacement inserts after the matched prefix, splitting the original heading at that character position. The trailing ` — rest of title` becomes part of the next line.

### Fix
Match the complete heading line using regex with `$` or match until the next blank line:

```python
import re

# Match the full heading line (including any suffix after the prefix)
content = re.sub(
    r'(## Short heading prefix[^\n]*\n\n)',
    r'\1**ID:** GE-0042\n',
    content, count=1
)
```

`[^\n]*` captures everything to the end of the heading line. The replacement inserts after the full heading + blank line, before `**Stack:**`.

### Why non-obvious
The partial match looks correct in isolation — the prefix is right, and the replacement adds after it. The bug only appears when the heading contains more text after the matched prefix, which is invisible at the point of writing the replacement. Searching for the full heading text manually works; using the prefix in code fails silently.

*Score: 10/15 · Included because: silent corruption, non-obvious cause, common when scripting markdown edits · Reservation: fairly basic string-matching lesson, but the markdown-heading context makes it concrete*
