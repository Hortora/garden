# Garden Submission

**Date:** 2026-04-07
**Submission ID:** GE-0088
**Type:** technique
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Fixing html2text stripping trailing spaces inside bold/italic elements
**Suggested target:** `tools/html2text.md` (same file as GE-0082)
**Labels:** `#html2text` `#beautifulsoup` `#preprocessing`

---

## Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text

**Stack:** Python html2text (all versions), BeautifulSoup4 (all versions)
**What it achieves:** Preserves trailing spaces that exist inside inline elements (`<b>`, `<em>`, `<code>`, etc.) in the html2text Markdown output, without adding spaces where none existed in the original HTML.
**Context:** html2text strips trailing whitespace inside bold/italic markers. `<b>Name </b>(text)` → `**Name**(text)`. This is wrong when the space was genuine. Moving the space to after the closing tag before html2text runs causes html2text to see `<b>Name</b> (text)` and preserve it.

### The technique

Apply this to the BeautifulSoup article element before calling html2text:

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
        if trailing:                                   # only when space genuinely exists
            last.replace_with(NavigableString(stripped))
            sib = tag.next_sibling
            if isinstance(sib, NavigableString):
                sib.replace_with(NavigableString(trailing + str(sib)))
            else:
                tag.insert_after(NavigableString(trailing))
```

### Why this is non-obvious
The obvious fix is post-processing: `re.sub(r'(\*+)\(', r'\1 (', body)`. This adds a space before every `**(`, including cases where the original HTML had no space at all (`<b>Name</b>(text)` — no trailing space). The pre-processing approach only runs when trailing whitespace actually existed, making it semantically correct.

Alternatives that don't work:
- `&nbsp;` substitution → becomes `\xa0` inside `**`, not between them and `(`
- html2text subclass overriding `handle_data` → breaks leading-space suppression, produces `** text` after opening markers

### When to use it
- Any HTML→Markdown pipeline using html2text when inline elements may have trailing whitespace
- Particularly: `<b>Name </b>(Affiliation)` patterns (common in blog post speaker lists, bibliography entries)
- Before html2text, never after

*Score: 11/15 · Included because: non-obvious correct fix for a documented html2text quirk, prevents incorrect alternative · Reservation: preprocessing step adds complexity to the pipeline*
