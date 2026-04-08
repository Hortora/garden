# Browser Testing Gotchas

---

## Browser cache hides a server fix — tests pass, user still sees the bug

**ID:** GE-0015
**Stack:** Any web application, any browser — universal
**Symptom:** Tests confirm the file written to disk is clean. The HTTP response is clean. But the user refreshes the browser and still sees the old garbled content. Multiple test runs all pass. The bug appears not fixed despite being fixed.
**Context:** A file was written with bad content by a buggy server. The server was fixed and the file regenerated cleanly. Tests verified disk file and HTTP response are clean. User did a normal browser refresh and still saw the old broken version.

### What was tried (didn't work)
- Regenerated the file — disk confirmed clean
- Verified HTTP response — clean
- Tests pass at every layer
- Normal browser refresh (`F5` / `Cmd+R`) — still showing old content

### Root cause

The browser cached the old broken file. A normal refresh reloads the page but often revalidates resources against the cache using `If-Modified-Since` — the server may return 304 Not Modified and the browser serves the cached version regardless of the disk file's updated content.

### Fix

**Hard refresh:** `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows/Linux) — bypasses the cache completely and fetches all resources fresh.

Or open in a private/incognito window, which has no cache.

For a permanent solution: add the Playwright browser render layer to your test suite (see GE-0018) — it catches cache-related regressions automatically.

### Why this is non-obvious

Tests pass at every layer (function output, disk file, HTTP response) but the user still sees the bug. It looks like the fix didn't work. The gap between "server sends clean content" and "browser renders clean content" is real and requires an additional test layer (Playwright) to close. Without it, you go in circles: "it's fixed" → "still broken" → "it IS fixed, trust the tests" → frustration.

The hard refresh shortcut is obvious in retrospect but easy to forget when your tests are all green and the user says it's still broken.

**See also:** GE-0018 for the layered testing approach that makes browser cache issues testable.

*Score: 13/15 (merge assessment) · Included because: "tests all green, user still sees bug" is a high-pain cycle; the disconnect between HTTP layer and browser render is not in most developers' mental model · Reservation: none identified*
