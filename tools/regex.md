# Regex Gotchas and Techniques

---

## Python `format(?:ting|ted|s)?` matches "formats" (plural noun) — false positive in text classifiers

**ID:** GE-0042
**Stack:** Python (all versions), `re` module
**Symptom:** A commit like "adopt official formats and reduce custom code by 92%" is classified as trivial/formatting rather than functional. No error — the classification silently succeeds with the wrong result.
**Context:** When building regex-based text classifiers that look for formatting-related words to exclude trivial changes. The plural form "formats" matches the optional `s?` suffix intended to catch "formatted" and "formatting".

### What was tried (didn't work)

- Pattern `r"\bformat\b"` — does NOT match "formatting" or "formatted" (word boundary after "t")
- Added `s?` to catch plurals: `format(?:ting|ted|s)?` — catches "formats" as a side effect
- Tested against "Mermaid format" — no match but "official formats" → match

### Root cause

The optional group `(?:ting|ted|s)?` includes `s?` which matches the plural noun "formats". The word boundary `\b` at the end of the full pattern follows the `s`, so `\bformats\b` matches perfectly — it is a valid word. The pattern doesn't distinguish between "format" used as a verb/adjective (formatting activity) and "formats" used as a plural noun (file formats, output formats).

### Fix

Remove `s?` from the optional group. Use `format(?:ting|ted)?` to match only the verb/adjective forms:

```python
# Before (matches "formats" — false positive)
TRIVIAL_RE = re.compile(
    r"\b(typo|whitespace|format(?:ting|ted|s)?|spelling)\b",
    re.IGNORECASE,
)

# After (only matches "format", "formatting", "formatted")
TRIVIAL_RE = re.compile(
    r"\b(typo|whitespace|format(?:ting|ted)?|spelling)\b",
    re.IGNORECASE,
)
```

If plural detection is genuinely needed for other words, enumerate the specific plurals explicitly rather than using `s?` — e.g. `(?:typo|typos)` — so it's intentional.

### Why this is non-obvious

The intent of `format(?:ting|ted|s)?` looks reasonable — "match format and its variants". The bug only surfaces when the text being classified uses "formats" as a noun in a positive/functional context. A developer testing with "fix formatting" and "reformat code" would see all expected matches and not think to test "adopt official formats", which reads nothing like a formatting commit.

*Score: 11/15 · Included because: silent false-positive classification with a pattern that looks correct at a glance; common mistake when building text classifiers with optional suffix groups · Reservation: only fails for noun usage*

---

## Regex matching social platform names silently strips content paragraphs that mention those platforms as topics

**ID:** GE-0086
**Stack:** Python (any version), any regex-based HTML metadata/chrome removal
**Symptom:** A content paragraph like `"I've set up a twitter account and will send updates..."` is silently removed during HTML processing. No error. The generated output is shorter than expected with no indication of what was stripped.
**Context:** HTML-to-Markdown pipelines that strip social sharing widgets using a regex like `re.compile(r'addtoany|linkedin|twitter|facebook|reddit|tumblr', re.I)` applied to all `<p>` element text.

### Root cause
Sharing-widget detection patterns that match social platform names in running text are too broad. A WordPress sharing widget says "Share on Twitter" (short, no substantive content). A content paragraph might say "follow us on Twitter at twitter.com/handle" (also short, mentions Twitter). A character-length threshold alone cannot distinguish them.

### Fix
Require that the paragraph looks like a sharing widget in at least one of two specific ways:

```python
_SOCIAL_PLATFORM_RE = re.compile(
    r'addtoany|linkedin|twitter|facebook|reddit|tumblr', re.I)
_SOCIAL_SHARE_URL_RE = re.compile(
    r'twitter\.com/intent|facebook\.com/sharer|linkedin\.com/share'
    r'|reddit\.com/submit|plus\.google\.com/share|t\.co/', re.I)

if _SOCIAL_PLATFORM_RE.search(combined):
    is_sharing_url = _SOCIAL_SHARE_URL_RE.search(hrefs)   # actual sharing URL
    is_bare_label  = len(text_nospace) < 50 and not hrefs  # e.g. "Share on Twitter"
    if is_sharing_url or is_bare_label:
        tag.decompose()
```

Sharing widgets use specific URL patterns (`/intent/tweet`, `/sharer`) that profile links do not. Bare label text ("Share on Twitter") is very short and has no links.

### Why this is non-obvious
The removal is silent — no log entry, no warning, no empty-body indicator until the full pipeline runs. The symptom (shorter output) looks like a conversion failure or a missing section. Tracing backwards to a regex that matched "twitter" in running prose text requires stepping through the entire stripping pipeline.

*Score: 9/15 · Included because: silent data loss, cross-project regex pattern, non-obvious root cause · Reservation: somewhat specific to HTML-to-MD pipelines*
