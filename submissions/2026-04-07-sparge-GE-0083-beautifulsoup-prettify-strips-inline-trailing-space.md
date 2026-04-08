# Garden Submission

**Date:** 2026-04-07
**Submission ID:** GE-0083
**Type:** gotcha
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Making trailing-whitespace adjacency visible in the HTML source editor
**Suggested target:** `tools/html2text.md` (same file as GE-0082)

---

## BeautifulSoup `prettify()` silently discards trailing whitespace from inline element text nodes

**Stack:** Python BeautifulSoup4 (all versions, html.parser and lxml)
**Symptom:** `<b>Name </b>` prettifies to `<b>\n  Name\n</b>` — the trailing space becomes invisible indentation. Reading the prettified output back gives `"Name"` (no trailing space). There is no warning and the round-trip appears identical to the human eye.
**Context:** Any inline element (`<b>`, `<strong>`, `<em>`, `<i>`, `<a>`, etc.) whose last text node has trailing whitespace. The space is converted to the indentation whitespace before the closing tag line — structurally it disappears from the text content.

### What was tried (didn't work)
- Reading the text node content after prettify and expecting to find the trailing space — it is gone
- Post-processing the prettified output to collapse inline elements (Step 1 regex) without `.strip()` — the regex captures the content correctly but BS4 had already discarded the space from the NavigableString's text

### Root cause
BeautifulSoup's `prettify()` inserts newlines and indentation around *every* tag, including inline elements. The trailing space in `"Name "` is not preserved as text content — it is consumed as part of the whitespace formatting between the text and the closing tag. This happens at the BS4 serialisation level, before any post-processing.

### Fix
Do not rely on prettified output to recover trailing-space information. Instead, detect adjacency *before* prettify by scanning the original DOM:

```python
from bs4 import NavigableString, Tag

# Detect: closing inline tag immediately followed by non-whitespace
for tag in article.find_all(['b', 'strong', 'em', 'i']):
    sib = tag.next_sibling
    if isinstance(sib, NavigableString) and sib and not sib[0].isspace():
        # This element is adjacent to non-whitespace — trailing space (if any)
        # was inside the tag and will be invisible after prettify()
        pass  # mark, annotate, or process before prettifying
```

Or use the WORD JOINER marker technique (GE-0089) to preserve adjacency through prettify.

### Why this is non-obvious
The prettified output *looks* correct — `<b>\n  Name\n</b>` appears to have the name and closing tag separated by formatting whitespace. Only by comparing the original text node content (`"Name "`) with what gets recovered after prettify (`"Name"`) does the loss become apparent. There is no API or option in BS4 to suppress this for inline elements.

*Score: 12/15 · Included because: silent data loss, cross-project, non-obvious mechanism · Reservation: specific to inline-element trailing-space scenarios*
