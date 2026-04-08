# BeautifulSoup Gotchas

---

## BeautifulSoup lxml parser double-encodes non-ASCII when input str contains `<meta charset>`

**ID:** GE-0008
**Stack:** Python, BeautifulSoup4 (all versions), lxml parser
**Symptom:** Non-ASCII characters — em dashes (—), curly quotes (""), en dashes (–) — appear as `ÃÂÃÂ¢ÃÂÃÂÃÂÃÂ` in prettified HTML output. Symptom looks like file I/O encoding, browser charset mismatch, or database encoding problem. No error is raised.
**Context:** Calling `BeautifulSoup(str_input, 'lxml').prettify()` on HTML that contains `<meta charset="utf-8">` — common in any archived or scraped HTML from a real website.

### What was tried (didn't work)
- Checked file I/O encoding — file was read correctly with `encoding='utf-8'`
- Checked browser charset — ruled out as browser issue
- Checked if the source HTML was already garbled — it was clean
- Assumed the issue was downstream (rendering, markdown generation) — incorrect

### Root cause
lxml is designed to parse **bytes**, not Python str. When given a Python str containing `<meta charset="utf-8">`, lxml does charset sniffing: it re-encodes the str to UTF-8 bytes internally (to match the declared charset), then serialises those bytes treating them as Latin-1 — producing double-encoded garbage for every non-ASCII character. `html.parser` makes no such transformation; it treats the Python str input as-is with no charset sniffing.

### Fix
Use `html.parser` instead of `lxml` when the input is already a decoded Python str:

```python
# ❌ Causes double-encoding when HTML contains <meta charset="utf-8">
content = BeautifulSoup(raw_str, 'lxml').prettify()

# ✅ Treats str as-is, no charset sniffing
content = BeautifulSoup(raw_str, 'html.parser').prettify()
```

Add a runtime guard after the transformation as a safety net:
```python
content = BeautifulSoup(raw_str, 'html.parser').prettify()
if 'ÃÂÃÂ' in content:
    # Should never happen with html.parser, but guard against future regressions
    log.warning('prettify produced garbled output — falling back to raw')
    content = raw_str
```

### Why this is non-obvious
The symptom (garbled characters) points everywhere except parser choice — file I/O, database encoding, browser rendering. The connection between the lxml parser and double-encoding is not documented anywhere in BeautifulSoup's docs. The fix (changing one word: `'lxml'` → `'html.parser'`) is disproportionately small relative to how long the debugging takes. Any developer who knows lxml is "better/faster" than html.parser will reach for it first — and get burned on any real-world HTML with a charset meta tag.

*Score: 14/15 · Included because: symptoms actively mislead across multiple wrong hypotheses; fix is one word; undocumented and ubiquitous · Reservation: some Stack Overflow threads cover this; targeted search may surface the answer*

---

## Hardcoded path traversal fails silently when scanning file copies in an alternate directory

**ID:** GE-0016
**Stack:** Python, BeautifulSoup4 (any version), any pipeline scanning files from multiple locations
**Symptom:** A bulk scan reports hundreds or thousands of "missing local image" errors. On investigation, the image files exist on disk at the expected paths. No exception is raised; the check silently reports every image as missing.
**Context:** A multi-stage pipeline where HTML files exist in two locations — an original directory and a copy (enriched, cached, transformed). The scan runs against the copy, but path resolution is hardcoded relative to the original.

### What was tried (didn't work)
- Verified image files exist on disk — they do
- Checked the HTML src attributes — they are correct relative paths
- Assumed assets were missing — they were not

### Root cause

The check navigates a fixed number of directory levels up from the scanned file to find the assets base directory:

```python
# Hardcoded assumption: HTML is 3 levels deep in posts/author/slug.html
legacy_dir = post_path.parent.parent.parent
abs_path = legacy_dir / rel_path
```

When the scanned file is a copy at `project/{id}/enriched/{slug}.html`, navigating 3 levels up lands at `project/` — not the assets directory. All asset lookups fail silently, producing 100% false positives.

### Fix

Pass the canonical source directory explicitly so path resolution is independent of where the scanned file lives:

```python
def check_missing_local_images(article, post_path, posts_dir=None):
    # posts_dir: canonical source location from project config
    # post_path: the file being scanned (may be a copy)
    if posts_dir is not None:
        base_dir = posts_dir.parent.parent  # resolve from known-good location
    else:
        base_dir = post_path.parent.parent.parent  # legacy fallback
    abs_path = base_dir / rel_path
```

Pass `posts_dir` from project config rather than inferring it from `post_path`.

### Why this is non-obvious

The check works correctly when scanning original files but silently produces 100% false positives when scanning copies in a different directory. There is no exception — just wrong results. The large error count (hundreds of "missing" images) looks plausible for a large archive, masking that every single one is a false positive. Any pipeline that scans files from multiple locations (original + enriched + cached + archived) will hit this if paths are hardcoded.

*Score: 13/15 (merge assessment) · Included because: 100% false positive rate with plausible-looking count is a high-pain silent failure · Reservation: root cause is a hardcoded assumption which is a known class of bug*

---

## `html.parser` does not add `<body>` wrapper to fragments; `.body.next` returns None

**ID:** GE-0017
**Stack:** Python, BeautifulSoup4 (any version), html.parser and lxml parsers
**Symptom:** After switching BeautifulSoup from `'lxml'` to `'html.parser'`, code that worked correctly raises `AttributeError: 'NoneType' object has no attribute 'next'` on roughly 20% of documents. The remaining 80% work fine.
**Context:** A pipeline switches parsers for an unrelated reason (e.g. fixing a charset encoding bug). Code that parses small HTML fragments (`<blockquote>...</blockquote>`, `<p>key</p>`) to get a Tag object starts raising AttributeError on that fraction of documents.

### What was tried (didn't work)
- Re-checked the HTML content — looked normal
- Verified the fragments were valid HTML
- Assumed it was a content issue with those specific documents

### Root cause

`lxml` always wraps parsed content in a full `<html><body>` structure, even for fragments. `html.parser` does not — it parses the fragment as-is without a body wrapper.

```python
from bs4 import BeautifulSoup

html = '<blockquote><strong>test</strong></blockquote>'

# lxml — adds <body>:
BeautifulSoup(html, 'lxml').body
# → <body><blockquote>...</blockquote></body>

# html.parser — no body wrapper:
BeautifulSoup(html, 'html.parser').body
# → None
```

Code using `.body.next` to extract the first element of a parsed fragment crashes with `AttributeError` when switching to `html.parser`.

### Fix

Replace `.body.next` with `.find()` — it retrieves the first element regardless of whether a body wrapper exists:

```python
# ❌ Breaks with html.parser (body is None)
element = BeautifulSoup(fragment_html, 'html.parser').body.next

# ✅ Works with both parsers
element = BeautifulSoup(fragment_html, 'html.parser').find()
```

### Why this is non-obvious

The bug only manifests on documents that exercise fragment-parsing code paths. Clean full-page HTML works fine. This creates a confusing 80/20 failure pattern: most documents succeed, some fail with a cryptic `NoneType` error that doesn't point to the parser choice as the cause. The root issue — two parsers produce different tree shapes for fragment input — is documented in BS4 docs but easy to miss when migrating parsers for an unrelated reason.

*Score: 13/15 · Included because: 80/20 failure split looks like a content bug not a parser bug; `.find()` fix is simple but requires knowing why · Reservation: BS4 docs do mention the difference*
