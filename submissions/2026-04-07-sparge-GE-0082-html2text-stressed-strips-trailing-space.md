# Garden Submission

**Date:** 2026-04-07
**Submission ID:** GE-0082
**Type:** gotcha
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Fixing MD validator false positives where `**Name**(Org)` didn't match HTML plain text `Name (Org)`
**Suggested target:** `tools/html2text.md` (new file — header: `# html2text Gotchas and Techniques`)

---

## html2text strips trailing whitespace inside bold/italic markers via internal `stressed` flag

**Stack:** Python html2text (all versions — behaviour is in core handle_data logic)
**Symptom:** `<b>Name </b>(text)` converts to `**Name**(text)` — the space that was trailing inside the `<b>` tag disappears entirely. The output looks like there was never a space; no warning is emitted.
**Context:** Any HTML with inline formatting where the last text node inside a bold/italic element has trailing whitespace, and the following content begins with `(` or another non-space character.

### What was tried (didn't work)
- Post-processing regex `re.sub(r'(\*+)\(', r'\1 (', body)` — adds space before every `**(`, even when the original had no space at all (incorrect)
- `&nbsp;` substitution before html2text — `&nbsp;` converts to `\xa0` inside the `**` markers, not between them and `(`; the `(` still runs directly into `**`
- Subclassing html2text and overriding `handle_data` to use `lstrip()` instead of `strip()` — breaks leading-space suppression (`** text` with space after opening marker becomes invalid Markdown)

### Root cause
html2text sets `self.stressed = True` when a bold/italic opening tag is processed. In `handle_data()`, the first `if self.stressed:` branch calls `data = data.strip()` — stripping ALL whitespace from the first text node, including trailing spaces. This is not documented anywhere in the html2text README, API reference, or docstrings. Only discoverable by reading `html2text/__init__.py`.

### Fix
Move trailing whitespace from *inside* the inline element to *after* the closing tag in the BeautifulSoup DOM **before** calling html2text. Then html2text sees the space outside the element and preserves it:

```python
from bs4 import NavigableString, Tag

INLINE_TAGS = ['b', 'strong', 'em', 'i', 'del', 's', 'strike', 'code', 'u', 'a']

for tag in list(article.find_all(INLINE_TAGS)):
    if not isinstance(tag, Tag) or not tag.contents:
        continue
    last = tag.contents[-1]
    if isinstance(last, NavigableString):
        stripped = str(last).rstrip()
        trailing = str(last)[len(stripped):]
        if trailing:
            last.replace_with(NavigableString(stripped))
            sib = tag.next_sibling
            if isinstance(sib, NavigableString):
                sib.replace_with(NavigableString(trailing + str(sib)))
            else:
                tag.insert_after(NavigableString(trailing))
```

This preserves the space only where one genuinely existed — unlike post-processing which adds space unconditionally.

### Why this is non-obvious
The symptom (`**Name**(text)`) misleads in two directions: it looks like a missing space *after* the closing `**`, so fixes target the MD output rather than the HTML input. The root cause — an internal flag stripping the trailing space *inside* the element before html2text even writes the `**` — is invisible from the output alone and undocumented.

*Score: 13/15 · Included because: cross-project, high pain, multiple failed approaches · Reservation: only affects the specific trailing-space-before-punctuation pattern*
