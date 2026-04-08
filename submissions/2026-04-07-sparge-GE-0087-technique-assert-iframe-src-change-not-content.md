# Garden Submission

**Date:** 2026-04-07
**Submission ID:** GE-0087
**Type:** technique
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Writing a Playwright test for the HTML editor save→viewer update flow
**Suggested target:** `tools/playwright.md` (same file as GE-0084, GE-0085)
**Labels:** `#testing` `#playwright` `#browser-caching`

---

## Assert that `iframe.src` changes after a save, not that the iframe content changed

**Stack:** Playwright (Python or JS, headless Chromium, all versions)
**What it achieves:** A test that reliably detects whether a save operation actually forces the browser to re-fetch the iframe content, rather than serving a cached response.
**Context:** Any test where a save operation should cause an iframe to display updated content. The naive assertion checks `iframe.contentDocument.body.innerText` — this passes in headless mode (which re-fetches) but produces a false green for real-browser behaviour (which serves cache).

### The technique

```python
# Capture the src BEFORE the save operation
src_before = pg.evaluate("() => document.getElementById('my-iframe').src")

# ... trigger the save (button click, form submit, etc.) ...
pg.wait_for_selector('#editor', state='hidden', timeout=10000)  # save completion signal

# Assert the src URL changed — this is the only reliable cross-environment signal
src_after = pg.evaluate("() => document.getElementById('my-iframe').src")

assert src_after != src_before, (
    'iframe.src was not updated after save. '
    'Real browsers serve the cached response for an unchanged URL — '
    'the edit will be invisible until a hard refresh. '
    f'src was: {src_before!r}'
)
```

The correct server-side fix is to update `iframe.src` with a new cache-bust timestamp after each save:
```javascript
// In the save success handler:
iframe.src = `/api/posts/${slug}/view?v=${Date.now()}`;
```

### Why this is non-obvious
The content assertion (`innerText contains new text`) is the natural thing to write. It passes in every automated run because headless Chromium doesn't cache aggressively. The bug only manifests in real browser sessions, is reported as a UX problem ("my save didn't work"), and is not reproducible in the test suite — making it look like an intermittent issue rather than a test reliability problem. The `src` URL is the only property that reflects whether the application *forced* a re-fetch.

### When to use it
- After any operation that updates server-side content rendered in an iframe
- When the iframe reloads by the application setting `iframe.src` (with or without cache-busting)
- As the primary assertion; content assertions are secondary

*Score: 13/15 · Included because: non-obvious, cross-project, prevents a class of false-green tests · Reservation: specific to iframe + caching scenarios*
