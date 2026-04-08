# Garden Submission

**Date:** 2026-04-07
**Submission ID:** GE-0084
**Type:** gotcha
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Testing that the HTML editor save button updates the iframe viewer immediately
**Suggested target:** `tools/playwright.md` (new file — header: `# Playwright Gotchas and Techniques`)

---

## Headless Playwright does not cache iframe responses the way real browsers do — content assertions give false passes

**Stack:** Playwright (Python, headless Chromium, all recent versions)
**Symptom:** A test asserting that `iframe.contentDocument.body.innerText` contains newly-saved content passes in CI (Playwright headless), but the user's real browser shows stale content after the same save operation. The test gives a false green.
**Context:** Any test that saves to a server-side resource and then checks the rendered content of an `<iframe>` that loads from that resource. The iframe's `src` URL was not updated after the save — only the server-side resource changed.

### What was tried (didn't work)
- Asserting the iframe's text content after save — passed in headless mode because headless Chromium re-fetched without caching; failed for real users whose browsers served the cached response

### Root cause
Headless Chromium (used by Playwright) applies less aggressive HTTP caching than a real browser session. When an iframe `src` URL is unchanged but the server-side resource it points to has been updated, headless Chromium often re-fetches and shows the new content. Real browsers serve the cached response for the same unchanged URL until the cache expires or the URL changes.

### Fix
Assert that `iframe.src` changes to a new URL (new cache-bust timestamp), not that the content changed:

```python
src_before = pg.evaluate("() => document.getElementById('my-iframe').src")

# ... trigger the save action ...

src_after = pg.evaluate("() => document.getElementById('my-iframe').src")

assert src_after != src_before, (
    'iframe.src was not updated after save — real browsers will serve cached '
    'content. Fix: update iframe.src with a new cache-bust timestamp after save.'
)
```

This is the reliable cross-environment signal: the URL change is what forces real browsers to re-fetch. If the URL does not change, real users will see stale content regardless of what the test reports.

### Why this is non-obvious
The test passes — in CI, on the developer's machine, in every automated run. The bug only surfaces in the user's actual browser session. The failure mode (stale iframe content) looks exactly like a timing issue or a server error, not a test reliability problem. The fix is checking a URL attribute rather than content.

*Score: 12/15 · Included because: false CI pass masks production bug, cross-project, very non-obvious failure mode · Reservation: requires knowing that headless and real-browser caching differ*
