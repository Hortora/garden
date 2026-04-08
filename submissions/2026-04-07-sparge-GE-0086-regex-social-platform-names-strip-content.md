# Garden Submission

**Date:** 2026-04-07
**Submission ID:** GE-0086
**Type:** gotcha
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Debugging why convert_post produced empty MD for a post mentioning Twitter
**Suggested target:** `tools/regex.md` (existing)

---

## Regex matching social platform names silently strips content paragraphs that mention those platforms as topics

**Stack:** Python (any version), any regex-based HTML metadata/chrome removal
**Symptom:** A content paragraph like `"I've set up a twitter account and will send updates..."` is silently removed during HTML processing. No error. The generated output is shorter than expected with no indication of what was stripped.
**Context:** HTML-to-Markdown pipelines that strip social sharing widgets using a regex like `re.compile(r'addtoany|linkedin|twitter|facebook|reddit|tumblr', re.I)` applied to all `<p>` element text. A paragraph whose topic happens to be one of those platforms gets caught.

### What was tried (didn't work)
- Reducing the character-length threshold for the social platform regex (still stripped shorter content paragraphs)
- Checking for the platform name in hrefs only — missed some sharing widgets that use bare platform names in text without links

### Root cause
Sharing-widget detection patterns that match social platform names in running text are too broad. A WordPress sharing widget says "Share on Twitter" (short, no substantive content). A content paragraph might say "follow us on Twitter at twitter.com/handle" (also short, mentions Twitter). A character-length threshold alone cannot distinguish them.

### Fix
Require that the paragraph looks like a sharing widget in at least one of two specific ways, rather than matching on platform name alone:

```python
_SOCIAL_PLATFORM_RE = re.compile(
    r'addtoany|linkedin|twitter|facebook|reddit|tumblr', re.I)
_SOCIAL_SHARE_URL_RE = re.compile(
    r'twitter\.com/intent|facebook\.com/sharer|linkedin\.com/share'
    r'|reddit\.com/submit|plus\.google\.com/share|t\.co/', re.I)

# In the removal loop:
if _SOCIAL_PLATFORM_RE.search(combined):
    is_sharing_url = _SOCIAL_SHARE_URL_RE.search(hrefs)   # actual sharing URL
    is_bare_label  = len(text_nospace) < 50 and not hrefs  # e.g. "Share on Twitter"
    if is_sharing_url or is_bare_label:
        tag.decompose()
```

Sharing widgets use specific URL patterns (`/intent/tweet`, `/sharer`, etc.) that profile links do not. Bare label text ("Share on Twitter") is very short and has no links. Content paragraphs that mention platforms are longer and have profile-style hrefs.

### Why this is non-obvious
The removal is silent — no log entry, no warning, no empty-body indicator until the full pipeline runs. The symptom (shorter output) looks like a conversion failure or a missing section. Tracing backwards to a regex that matched "twitter" in running prose text requires stepping through the entire stripping pipeline.

*Score: 9/15 · Included because: silent data loss, cross-project regex pattern, non-obvious root cause · Reservation: somewhat specific to HTML-to-MD pipelines*
