# Playwright Gotchas

Discovered building Playwright-based UI test suites for web applications.

---

## `page.evaluate()` does not await async JavaScript functions

**ID:** GE-0101
**Stack:** Playwright 1.58.0 (Python), async JavaScript
**Symptom:** `page.evaluate('loadState()')` returns immediately. The async function starts but the test proceeds before it completes — badges don't update, counts stay stale. No exception is thrown.
**Context:** Any Playwright test calling a JS function that returns a Promise.

### What was tried (didn't work)
- `page.evaluate('loadState()')` + `page.wait_for_timeout(300)` — function started but didn't complete; 300ms wasn't deterministic
- `page.evaluate('loadState()')` + `page.wait_for_load_state('networkidle')` — raced; `networkidle` fired before JS Promise resolved

### Root cause
`page.evaluate()` serialises the return value. A Promise serialises as `{}` and `evaluate()` returns immediately without awaiting resolution. The async function runs in the background but the Python call stack has already moved on.

### Fix
```python
# ❌ doesn't wait
page.evaluate('loadState()')

# ✅ actually awaits
page.evaluate('async () => { await loadState(); }')
```

### Why this is non-obvious
`page.evaluate()` looks synchronous from the Python side. Nothing in the error output indicates timing — tests just see stale state with no exception. Developers assume evaluate() propagates async behaviour; it only does if you explicitly wrap with an async IIFE.

---

## `to_be_visible()` fails on elements inside collapsed parent containers

**ID:** GE-0102
**Stack:** Playwright 1.58.0 (Python), CSS `display:none` on parent
**Symptom:** `expect(locator).to_be_visible()` polls for 5 seconds and fails. Debug output shows the element IS found ("9 × locator resolved to `<button...>`") but reports "unexpected value: hidden".
**Context:** Any test asserting visibility of an element whose ancestor has `display:none`. Common with accordions, collapsed sections, hidden tabs, toggle-based UI.

### What was tried (didn't work)
- `expect(row.locator('.btn-install')).to_be_visible()` — element found but hidden; timed out
- Increased timeout — same result; element is genuinely hidden, not just slow to appear

### Root cause
`to_be_visible()` checks computed visibility across the entire ancestor chain. If any ancestor has `display:none`, the element is hidden even if it matches the selector. The locator resolves (element exists) but visibility fails because a parent container is collapsed.

### Fix
```python
# Expand collapsible containers before asserting
page.evaluate(
    "BUNDLE_IDS.forEach(id => document.getElementById(id).classList.add('open'))"
)
page.wait_for_timeout(200)
expect(row.locator('.btn-install')).to_be_visible()  # now works
```

### Why this is non-obvious
"Locator resolved" implies the element exists. "Unexpected value: hidden" looks like the element itself has `display:none`, not a parent. The "9 ×" polling count confirms Playwright found it every time — consistently hidden. Developers focus on the element's own CSS, not its ancestor chain.

---

## `wait_for_selector(':not(.open)')` waits for visible, but the closed modal is `display:none`

**ID:** GE-0103
**Stack:** Playwright 1.58.0 (Python), CSS class-toggled modal visibility
**Symptom:** `page.wait_for_selector('#overlay:not(.open)', timeout=3000)` times out. The modal closed (class `open` removed) but the assertion fails because `wait_for_selector` defaults to `state='visible'` — and the closed overlay is `display:none`.
**Context:** Modals or any element whose visibility is controlled by adding/removing a CSS class.

### What was tried (didn't work)
- `page.wait_for_selector('#overlay:not(.open)')` — selector is correct but default `state='visible'` requires the element to be visible, which it never is when `display:none`

### Root cause
`wait_for_selector()` defaults to `state='visible'`. The selector `#overlay:not(.open)` is correct — it matches when `open` is absent — but the element at that point is `display:none`. The default requires both present AND visible.

### Fix
```python
# ❌ times out — looks for visible, but closed modal is display:none
page.wait_for_selector('#overlay:not(.open)', timeout=3000)

# ✅ explicitly waits for hidden state
page.locator('#overlay').wait_for(state='hidden', timeout=3000)
```

### Why this is non-obvious
`#overlay:not(.open)` reads naturally as "wait until overlay loses open class." But `wait_for_selector` interprets this as "find that element AND ensure it's visible" — impossible when `display:none`. The fix requires knowing `wait_for(state='hidden')` is the right API for class-toggled visibility.

---

## Generate realistic UI screenshots for blog posts using Playwright headless screenshots

**ID:** GE-0019
**Stack:** Python, playwright (sync API), any project where Playwright is already installed
**Labels:** `#technique` `#blogging` `#claude-cli`
**What it achieves:** Produces real PNG screenshots from HTML mockups — no image generation model needed. Claude can't generate image files, but it can generate HTML/CSS that looks like the real UI, and Playwright can screenshot that HTML headlessly.
**Context:** Writing blog posts or documentation that needs UI illustrations. Claude generates the HTML mockup; Playwright captures it as a PNG; the image drops straight into the post.

### The technique

```python
from playwright.sync_api import sync_playwright
from pathlib import Path

def screenshot_html(html_path: str, output_path: str, width: int = 1400, height: int = 900):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={'width': width, 'height': height})
        page.goto(f'file://{Path(html_path).resolve()}')
        page.wait_for_load_state('networkidle')
        page.screenshot(path=output_path, full_page=False)
        browser.close()

screenshot_html('mockup.html', 'assets/blog/screenshot.png')
```

Claude generates the HTML mockup styled to match the real application. Playwright screenshots it. The PNG drops into the blog post with a standard markdown image reference.

### Why this is non-obvious

Claude cannot generate image files. Most people stop there and either skip illustrations or use generic placeholder images. The workaround — generate HTML, screenshot with Playwright — is not obvious because it requires knowing that Playwright is already installed in many Python projects (it's used for browser testing in many pipelines), and that `file://` URLs work fine for local HTML files.

The result looks indistinguishable from a real screenshot because it *is* a real screenshot — just of a carefully crafted mockup rather than the live application.

### When to use it
- Blog posts about tools or UIs where a screenshot would make the writing concrete
- Documentation that needs UI illustrations without access to a live instance
- Any situation where Claude needs to produce an image file but can't

### Caveats
- Playwright must already be installed (`pip install playwright && playwright install chromium`)
- `wait_for_load_state('networkidle')` is important for mockups that load web fonts or external CSS
- For dark UIs, set the background explicitly in the HTML — some headless browsers default to white
- `full_page=False` captures the viewport; use `full_page=True` for long scrollable mockups

*Score: 10/15 (merge assessment) · Included because: workaround for Claude's inability to generate image files; HTML→screenshot is non-obvious; result is indistinguishable from real screenshots · Reservation: depends on Claude's image limitation which may change in future versions*

---

## Headless Playwright does not cache iframe responses the way real browsers do — content assertions give false passes

**ID:** GE-0084
**Stack:** Playwright (Python, headless Chromium, all recent versions)
**Symptom:** A test asserting that `iframe.contentDocument.body.innerText` contains newly-saved content passes in CI (Playwright headless), but the user's real browser shows stale content after the same save operation. The test gives a false green.
**Context:** Any test that saves to a server-side resource and then checks the rendered content of an `<iframe>` that loads from that resource. The iframe's `src` URL was not updated after the save.

### Root cause
Headless Chromium applies less aggressive HTTP caching than a real browser session. When an iframe `src` URL is unchanged but the server-side resource has been updated, headless Chromium often re-fetches and shows the new content. Real browsers serve the cached response for the same unchanged URL until the cache expires or the URL changes.

### Fix
Assert that `iframe.src` changes to a new URL (new cache-bust timestamp), not that the content changed. See GE-0087 for the full technique.

### Why this is non-obvious
The test passes in CI, on the developer's machine, in every automated run. The bug only surfaces in the user's actual browser session. The failure mode (stale iframe content) looks exactly like a timing issue or a server error, not a test reliability problem.

**See also:** GE-0087 (assert iframe.src change — the correct technique)

*Score: 12/15 · Included because: false CI pass masks production bug, cross-project, very non-obvious failure mode · Reservation: requires knowing headless and real-browser caching differ*

---

## Two `sync_playwright()` context managers in the same pytest session conflict with asyncio

**ID:** GE-0085
**Stack:** Playwright Python (sync API, all versions), pytest (all versions)
**Symptom:** `playwright._impl._errors.Error: It looks like you are using Playwright Sync API inside the asyncio loop. Please use the Async API instead.` — raised when a second `with sync_playwright() as p:` block is entered while another is still open.
**Context:** Two pytest fixtures in the same test module both use `with sync_playwright()`. One is module-scoped (stays open for the entire module run via `yield`). The second is class-scoped or function-scoped.

### Root cause
`sync_playwright().__enter__()` creates or detects an asyncio event loop. If one is already running (from the first fixture's context manager), the second attempt raises the error. Pytest runs module-scoped fixture teardown only after all tests in the module complete — so the two `with sync_playwright()` blocks overlap.

### Fix
Create a new page within the existing Playwright session instead of starting a new one:

```python
@pytest.fixture(scope='class')
def second_page(page):  # 'page' is the module-scoped fixture
    ctx = page.context.browser.new_context(viewport={'width': 1400, 'height': 900})
    pg = ctx.new_page()
    yield pg
    ctx.close()
```

Note: `page.context.new_page()` raises `Error: Please use browser.new_context()` — the implicit context only allows one page.

### Why this is non-obvious
The error message says "Sync API inside asyncio loop" — which sounds like a threading or async code problem, not a fixture lifecycle problem. The real cause (two `sync_playwright()` context managers whose lifetimes overlap due to pytest fixture scoping) is not mentioned in the error or in Playwright's documentation.

*Score: 11/15 · Included because: misleading error message, cross-project, non-obvious fix · Reservation: only hits when two Playwright fixtures coexist in a module*

---

## Assert that `iframe.src` changes after a save, not that the iframe content changed

**ID:** GE-0087
**Stack:** Playwright (Python or JS, headless Chromium, all versions)
**Labels:** `#testing` `#playwright` `#browser-caching`
**What it achieves:** A test that reliably detects whether a save operation actually forces the browser to re-fetch the iframe content, rather than serving a cached response.
**Context:** Any test where a save operation should cause an iframe to display updated content. The naive assertion checks `iframe.contentDocument.body.innerText` — this passes in headless mode (which re-fetches) but produces a false green for real-browser behaviour (which serves cache). See GE-0084.

### The technique

```python
# Capture the src BEFORE the save operation
src_before = pg.evaluate("() => document.getElementById('my-iframe').src")

# ... trigger the save ...
pg.wait_for_selector('#editor', state='hidden', timeout=10000)  # save completion signal

# Assert the src URL changed — the only reliable cross-environment signal
src_after = pg.evaluate("() => document.getElementById('my-iframe').src")

assert src_after != src_before, (
    'iframe.src was not updated after save — real browsers will serve cached content. '
    f'src was: {src_before!r}'
)
```

The correct server-side fix is to update `iframe.src` with a new cache-bust timestamp after each save:
```javascript
iframe.src = `/api/posts/${slug}/view?v=${Date.now()}`;
```

### Why this is non-obvious
The content assertion (`innerText contains new text`) is the natural thing to write. It passes in every automated run because headless Chromium doesn't cache aggressively. The `src` URL is the only property that reflects whether the application *forced* a re-fetch.

### When to use it
- After any operation that updates server-side content rendered in an iframe
- As the primary assertion; content assertions are secondary

**See also:** GE-0084 (the gotcha this technique resolves)

*Score: 13/15 · Included because: non-obvious, cross-project, prevents a class of false-green tests · Reservation: specific to iframe + caching scenarios*

---

## Use `.locator().all()` not `.locator().nth(n)` when screenshotting multiple elements of the same class

**ID:** GE-0092
**Stack:** Playwright (Python), playwright.sync_api, browser automation
**Labels:** `#testing` `#automation`
**What it achieves:** Screenshot N elements matching a CSS class individually, saving each as a separate image file, without timeouts or selector failures.
**Context:** Automating element-level screenshots from an HTML page where multiple elements share the same CSS class.

### The technique

```python
# ✅ Get all matching elements as a list, then iterate
elements = page.locator(".diagram").all()

for i, el in enumerate(elements):
    el.screenshot(path=f"output/diagram-{i}.png")
```

### What was tried (didn't work)

```python
# ❌ Times out — do not use
for i in range(4):
    page.locator(".diagram").nth(i).screenshot(path=f"diagram-{i}.png")
```
`TimeoutError: Locator.screenshot: Timeout 30000ms exceeded` on the first call, even though `page.locator(".diagram").count()` correctly returns 4 and the elements are visible.

### Root cause
`.locator(".diagram").nth(n)` creates a new locator that re-evaluates the selector on each call. When combined with `.screenshot()`, Playwright's element handle lifecycle causes it to fail finding a stable element reference. `.all()` materialises all matching elements into a list of stable element handles upfront.

### Why this is non-obvious
The error (timeout) gives no indication that the selector strategy is wrong; it looks like the element simply isn't found. `.count()` confirming 4 elements makes the timeout even more confusing. `.all()` is not prominently documented as the preferred approach for this use case.

*Score: 10/15 · Included because: timeout error completely misleads; .all() is the non-obvious fix; common automation task · Reservation: may vary across Playwright versions*
