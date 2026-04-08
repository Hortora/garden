# html2text Gotchas and Techniques

Discovered building a blog migrator (sparge) converting HTML to Markdown via html2text and BeautifulSoup.

---

## html2text strips trailing whitespace inside bold/italic markers via internal `stressed` flag

**ID:** GE-0082
**Stack:** Python html2text (all versions — behaviour is in core handle_data logic)
**Symptom:** `<b>Name </b>(text)` converts to `**Name**(text)` — the space that was trailing inside the `<b>` tag disappears entirely. The output looks like there was never a space; no warning is emitted.
**Context:** Any HTML with inline formatting where the last text node inside a bold/italic element has trailing whitespace, and the following content begins with `(` or another non-space character.

### What was tried (didn't work)
- Post-processing regex `re.sub(r'(\*+)\(', r'\1 (', body)` — adds space before every `**(`, even when the original had no space at all
- `&nbsp;` substitution before html2text — `&nbsp;` converts to `\xa0` inside the `**` markers, not between them and `(`
- Subclassing html2text and overriding `handle_data` to use `lstrip()` instead of `strip()` — breaks leading-space suppression

### Root cause

html2text sets `self.stressed = True` when a bold/italic opening tag is processed. In `handle_data()`, the first `if self.stressed:` branch calls `data = data.strip()` — stripping ALL whitespace from the first text node, including trailing spaces. See GE-0090 for the full undocumented `stressed` flag documentation.

### Fix

Move trailing whitespace from inside the inline element to after the closing tag in the BeautifulSoup DOM **before** calling html2text:

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

See GE-0088 for the full technique with rationale.

### Why this is non-obvious

The symptom (`**Name**(text)`) misleads in two directions: it looks like a missing space *after* the closing `**`, so fixes target the MD output rather than the HTML input. The root cause — an internal flag stripping the trailing space *inside* the element before html2text even writes the `**` — is invisible from the output alone and undocumented.

**See also:** GE-0088 (pre-processing technique fix), GE-0090 (stressed flag undocumented internals), GE-0083 (BS4 prettify discards same trailing space)

*Score: 13/15 · Included because: cross-project, high pain, multiple failed approaches · Reservation: only affects the specific trailing-space-before-punctuation pattern*

---

## BeautifulSoup `prettify()` silently discards trailing whitespace from inline element text nodes

**ID:** GE-0083
**Stack:** Python BeautifulSoup4 (all versions, html.parser and lxml)
**Symptom:** `<b>Name </b>` prettifies to `<b>\n  Name\n</b>` — the trailing space becomes invisible indentation. Reading the prettified output back gives `"Name"` (no trailing space). There is no warning and the round-trip appears identical to the human eye.
**Context:** Any inline element (`<b>`, `<strong>`, `<em>`, `<i>`, `<a>`, etc.) whose last text node has trailing whitespace. The space is converted to the indentation whitespace before the closing tag line — structurally it disappears from the text content.

### What was tried (didn't work)
- Reading the text node content after prettify and expecting to find the trailing space — it is gone
- Post-processing the prettified output to collapse inline elements without `.strip()` — BS4 had already discarded the space from the NavigableString's text

### Root cause

BeautifulSoup's `prettify()` inserts newlines and indentation around every tag, including inline elements. The trailing space in `"Name "` is consumed as part of the whitespace formatting between the text and the closing tag — lost at the BS4 serialisation level, before any post-processing.

### Fix

Do not rely on prettified output to recover trailing-space information. Instead, detect adjacency *before* prettify by scanning the original DOM, or use the WORD JOINER marker technique (GE-0089) to preserve adjacency information through prettify.

```python
from bs4 import NavigableString, Tag

# Detect: closing inline tag immediately followed by non-whitespace
for tag in article.find_all(['b', 'strong', 'em', 'i']):
    sib = tag.next_sibling
    if isinstance(sib, NavigableString) and sib and not sib[0].isspace():
        # This element is adjacent — process BEFORE prettifying
        pass
```

### Why this is non-obvious

The prettified output *looks* correct — `<b>\n  Name\n</b>` appears to have the name and closing tag separated by formatting whitespace. Only by comparing the original text node content (`"Name "`) with what gets recovered after prettify (`"Name"`) does the loss become apparent. There is no API or option in BS4 to suppress this for inline elements.

**See also:** GE-0082 (html2text strips same space), GE-0089 (WORD JOINER marker technique)

*Score: 12/15 · Included because: silent data loss, cross-project, non-obvious mechanism · Reservation: specific to inline-element trailing-space scenarios*

---

## Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text

**ID:** GE-0088
**Stack:** Python html2text (all versions), BeautifulSoup4 (all versions)
**Labels:** `#html2text` `#beautifulsoup` `#preprocessing`
**What it achieves:** Preserves trailing spaces that exist inside inline elements (`<b>`, `<em>`, `<code>`, etc.) in the html2text Markdown output, without adding spaces where none existed in the original HTML.
**Context:** html2text strips trailing whitespace inside bold/italic markers (see GE-0082). `<b>Name </b>(text)` → `**Name**(text)`. Moving the space to after the closing tag before html2text runs causes html2text to see `<b>Name</b> (text)` and preserve it.

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

### When to use it
- Any HTML→Markdown pipeline using html2text when inline elements may have trailing whitespace
- Particularly: `<b>Name </b>(Affiliation)` patterns (common in blog post speaker lists, bibliography entries)
- Before html2text, never after

**See also:** GE-0082 (the gotcha this fixes), GE-0090 (stressed flag internals)

*Score: 11/15 · Included because: non-obvious correct fix for a documented html2text quirk, prevents incorrect alternative · Reservation: preprocessing step adds complexity*

---

## Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()`

**ID:** GE-0089
**Stack:** Python BeautifulSoup4 (all versions), Python re
**Labels:** `#beautifulsoup` `#prettify` `#pattern`
**What it achieves:** Preserves information about which HTML elements were adjacent to non-whitespace content in the original DOM, surviving through `prettify()` which destroys that information by adding newlines everywhere.
**Context:** BS4 `prettify()` adds newlines around every tag including inline elements. After prettify, `<b>Name</b>(text)` and `<b>Name</b> (text)` look the same. Marking the following sibling with U+2060 before prettify lets you detect and rejoin them afterward.

### The technique

```python
import re
from bs4 import BeautifulSoup, NavigableString, Tag

MARKER = '\u2060'  # WORD JOINER — invisible, never appears in normal HTML

# Step 1: Before prettify — mark adjacent elements
for tag in soup.find_all(['b', 'strong', 'em', 'i']):
    if not isinstance(tag, Tag): continue
    sib = tag.next_sibling
    if isinstance(sib, NavigableString) and sib and not sib[0].isspace():
        sib.replace_with(NavigableString(MARKER + str(sib)))

# Step 2: Prettify
content = soup.prettify()

# Step 3: Collapse inline element content to single lines
_INLINE = r'(?:b|strong|em|i|code|a|abbr|cite|q|s|u|del|ins|mark|small|sub|sup)'
content = re.sub(
    rf'(<(?:{_INLINE})(?:\s[^>]*)?>)\n[ \t]*(.*?)\n[ \t]*(</(?:{_INLINE})>)',
    lambda m: m.group(1) + m.group(2) + m.group(3),
    content, flags=re.IGNORECASE,
)

# Step 4: Rejoin closing tags with MARKER-prefixed content
content = re.sub(
    rf'(</(?:{_INLINE})>)\n[ \t]*{re.escape(MARKER)}',
    r'\1', content, flags=re.IGNORECASE,
)

# Step 5: Clean up any remaining markers
content = content.replace(MARKER, '')
```

### Why this is non-obvious

U+2060 (WORD JOINER) is an invisible formatting character that acts as a non-breaking zero-width space. It never appears in normal HTML content, so it can serve as a unique marker without risk of collision. After `prettify()`, it appears as a leading invisible character on the following sibling's line — exactly the position needed for the regex to detect and collapse the line break.

### When to use it
- When you need to preserve two-state information (adjacent vs separated) through a prettifier that collapses both states to the same output
- Only useful when both the marker insertion and the post-processing happen in the same pipeline stage

**See also:** GE-0083 (the prettify problem this solves)

*Score: 10/15 · Included because: non-obvious use of invisible Unicode character as a reversible marker, cross-project pattern · Reservation: adds complexity; only necessary when prettify must be used*

---

## html2text `stressed` flag: causes `data.strip()` on first text node inside bold/italic — not documented anywhere

**ID:** GE-0090
**Stack:** Python html2text (all versions — the `stressed` flag has been in the codebase since at least 2012)
**What it is:** An internal boolean flag `self.stressed` that, when True, causes `handle_data()` to strip ALL whitespace from the text content (both leading and trailing) of the first text node encountered after an emphasis marker opens.
**How discovered:** Reading `html2text/__init__.py` source after no other explanation for the trailing-space stripping behaviour could be found.

### Description

In `html2text/__init__.py`:

```python
# When a bold/italic opening tag is processed:
self.stressed = True          # set in handle_tag() for b/strong/em/i

# In handle_data():
if self.stressed:
    data = data.strip()       # strips ALL whitespace — leading AND trailing
    self.stressed = False
    self.preceding_stressed = True
```

The `stressed` flag serves two purposes:
1. Strips leading whitespace from bold/italic content to prevent `** text**` (space after marker)
2. As a side effect, also strips trailing whitespace from `<b>text </b>` → `**text**`

Purpose (1) is valid Markdown behaviour. Purpose (2) destroys trailing spaces that were intentional in the original HTML.

### How to use it / where it appears

The flag is only set for `<b>`, `<strong>`, `<em>`, `<i>` (and similar emphasis tags — check `handle_tag()` in your version). It applies to the *first* text node after the opening tag. Subsequent text nodes inside the same element are not affected.

### Why it's not obvious

- The html2text README makes no mention of whitespace handling inside emphasis markers
- The API documentation does not describe this behaviour
- The flag name `stressed` gives no hint about whitespace stripping
- There is no configuration option to disable this stripping

### Caveats

The `stressed` flag was introduced to solve a real Markdown rendering problem (spaces after `**` break bold rendering in some parsers). Disabling it entirely breaks emphasis in a different way. The correct workaround is to move the trailing whitespace to after the closing tag before html2text processes it (see GE-0082, GE-0088).

**See also:** GE-0082 (the gotcha caused by this flag), GE-0088 (the fix)

*Score: 11/15 · Included because: only discoverable by source reading, explains non-obvious behaviour, directly useful for HTML→Markdown conversion · Reservation: may be partially documented in a changelog we didn't find*
