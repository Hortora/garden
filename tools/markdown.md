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

---

## Partial Heading Match in `str.replace()` Corrupts Markdown Headings When Heading Has a Suffix

**ID:** GE-0107
**Stack:** Python (any version), `str.replace()` or `str.split()`, any markdown file editing script

**Symptom:** After running a script that inserts content after a markdown heading, the heading is split mid-line. A heading like `## Title — subtitle` becomes:
```
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

---

## Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown

**ID:** GE-0108
**Stack:** GitHub Flavored Markdown, Typora, any Markdown renderer that allows inline HTML
**Labels:** `#markdown` `#documentation` `#blogging`
**What it achieves:** Floats an image left or right with text wrapping around it, in both GitHub-rendered Markdown and Typora. Works without CSS.
**Context:** Blog posts or documentation with thumbnail illustrations alongside text; any Markdown file that needs to render correctly on both GitHub and in Typora.

### The technique

```markdown
<img align="left" width="200" src="image.png" alt="description">
Text that wraps around the image starts immediately here — no blank line.

More paragraphs continue wrapping until the image height is exhausted.

<br clear="left">

This content starts below the image.
```

Key requirements:
1. **No blank line** between the `<img>` tag and the first text — a blank line breaks the float in Typora
2. **`<br clear="left">`** after the wrapped section to stop wrapping
3. **`align="left"` or `align="right"`** — not `style="float:left"` (GitHub strips style attributes)

### Why this is non-obvious
`style="float:left"` is the modern CSS equivalent and works in Typora but is stripped by GitHub's HTML sanitiser. `align` is a deprecated HTML 4 attribute that GitHub preserves (it predates the CSS security concern). The no-blank-line requirement for Typora is undocumented — a blank line causes Typora to treat the image as a block and ignore the float.

**See also:** GE-0020 (`typora-root-url` — related: Typora+Jekyll image rendering)

*Score: 12/15 · Included because: `style` is the natural first attempt, GitHub stripping it is not surfaced as an error, `align` as the fix is non-obvious; no-blank-line Typora requirement is undocumented · Reservation: `align` is deprecated HTML — may eventually stop working*

---
