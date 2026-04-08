# Garden Submission

**Date:** 2026-04-07
**Submission ID:** GE-0090
**Type:** undocumented
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Tracing why html2text strips trailing whitespace from inside bold/italic elements
**Suggested target:** `tools/html2text.md` (same file as GE-0082, GE-0088)

---

## html2text `stressed` flag: causes `data.strip()` on first text node inside bold/italic — not documented anywhere

**Stack:** Python html2text (all versions — the `stressed` flag has been in the codebase since at least 2012)
**What it is:** An internal boolean flag `self.stressed` that, when True, causes `handle_data()` to strip ALL whitespace from the text content (both leading and trailing) of the first text node encountered after an emphasis marker opens.
**How discovered:** Reading `html2text/__init__.py` source after no other explanation for the trailing-space stripping behaviour could be found

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
- The only mention of this in the codebase is a comment: `# self.stressed/self.preceding_stressed gets switched after the first call`
- There is no configuration option to disable this stripping

### Caveats
The `stressed` flag was introduced to solve a real Markdown rendering problem (spaces after `**` break bold rendering in some parsers). Disabling it entirely breaks emphasis in a different way. The correct workaround is to move the trailing whitespace to *after* the closing tag before html2text processes it (see GE-0082, GE-0088).

*Score: 11/15 · Included because: only discoverable by source reading, explains non-obvious behaviour, directly useful for anyone doing HTML→Markdown conversion · Reservation: may be partially documented in a changelog we didn't find*
