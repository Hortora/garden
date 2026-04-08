# Playwright Gotchas

Discovered building Playwright-based UI test suites for web applications.

---

## `page.evaluate()` does not await async JavaScript functions

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
