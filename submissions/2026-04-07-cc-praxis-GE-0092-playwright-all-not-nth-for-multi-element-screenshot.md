**Submission ID:** GE-0092
**Date:** 2026-04-07
**Project:** cc-praxis
**Type:** technique
**Stack:** Playwright (Python), playwright.sync_api, browser automation
**Labels:** #testing #automation
**Score:** 10/15
**Suggested target:** tools/playwright.md

---

## Use `.locator().all()` not `.locator().nth(n)` when screenshotting multiple elements of the same class

**What it achieves:** Screenshot N elements matching a CSS class individually,
saving each as a separate image file, without timeouts or selector failures.

**Context:** Automating element-level screenshots from an HTML page where
multiple elements share the same CSS class (e.g., `.diagram`, `.card`).

### The technique

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page(viewport={"width": 1200, "height": 900})
    page.goto("file:///path/to/file.html")
    page.wait_for_load_state("networkidle")

    # ✅ Get all matching elements as a list, then iterate
    elements = page.locator(".diagram").all()

    for i, el in enumerate(elements):
        el.screenshot(path=f"output/diagram-{i}.png")

    browser.close()
```

### What was tried (didn't work)

Using `.nth(n)` inside a loop with `.locator(".diagram").nth(i).screenshot()`:

```python
# ❌ Times out — do not use
for i in range(4):
    page.locator(".diagram").nth(i).screenshot(path=f"diagram-{i}.png")
```

This produces a `TimeoutError: Locator.screenshot: Timeout 30000ms exceeded`
on the first call, even though `page.locator(".diagram").count()` correctly
returns 4 and the elements are visible on the page.

### Root cause

`.locator(".diagram").nth(n)` creates a new locator that re-evaluates the
selector on each call. When combined with `.screenshot()`, Playwright's
element handle lifecycle causes it to fail finding a stable element reference.
`.all()` materialises all matching elements into a list of stable element
handles upfront, which then screenshot correctly.

### Why non-obvious

The nth-child CSS selector approach is the natural first attempt — it's how
you'd select individual elements in any other context. The error (timeout)
gives no indication that the selector strategy is wrong; it looks like the
element simply isn't found. `.count()` confirming 4 elements makes the
timeout even more confusing. `.all()` is not prominently documented as the
preferred approach for this use case.

*Score: 10/15 · Included because: timeout error completely misleads; .all()
is the non-obvious fix; common automation task ·
Reservation: may vary across Playwright versions*
