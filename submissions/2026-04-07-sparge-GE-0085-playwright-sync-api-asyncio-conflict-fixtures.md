# Garden Submission

**Date:** 2026-04-07
**Submission ID:** GE-0085
**Type:** gotcha
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Adding a class-scoped Playwright fixture to a test module that already had a module-scoped one
**Suggested target:** `tools/playwright.md` (same file as GE-0084)

---

## Two `sync_playwright()` context managers in the same pytest session conflict with asyncio

**Stack:** Playwright Python (sync API, all versions), pytest (all versions)
**Symptom:** `playwright._impl._errors.Error: It looks like you are using Playwright Sync API inside the asyncio loop. Please use the Async API instead.` — raised when a second `with sync_playwright() as p:` block is entered while another is still open (its fixture has not been torn down).
**Context:** Two pytest fixtures in the same test module both use `with sync_playwright()`. One is module-scoped (created first, stays open for the entire module run via `yield`). The second is class-scoped or function-scoped. When the second fixture starts, the module-scoped one's asyncio event loop is still running.

### What was tried (didn't work)
- Scoping the second fixture as `scope='class'` — still conflicts because the module-scoped fixture holds the event loop open throughout the module
- Trying to run the second fixture in a different test file — works, but splits related tests unnecessarily

### Root cause
`sync_playwright().__enter__()` creates or detects an asyncio event loop. If one is already running (from the first fixture's context manager), the second attempt raises the error. Pytest runs module-scoped fixture teardown only after all tests in the module complete — so the two `with sync_playwright()` blocks overlap.

### Fix
Create a new page within the *existing* Playwright session instead of starting a new one:

```python
@pytest.fixture(scope='class')
def second_page(page):  # 'page' is the module-scoped fixture
    # page.context is a single-page implicit context — use browser.new_context()
    ctx = page.context.browser.new_context(viewport={'width': 1400, 'height': 900})
    pg = ctx.new_page()
    # navigate, set up, etc.
    yield pg
    ctx.close()
```

`page.context.new_page()` raises `Error: Please use browser.new_context()` — the implicit context only allows one page. Use `page.context.browser.new_context().new_page()` instead.

### Why this is non-obvious
The error message says "Sync API inside asyncio loop" — which sounds like a threading or async code problem, not a fixture lifecycle problem. The real cause (two `sync_playwright()` context managers whose lifetimes overlap due to pytest fixture scoping) is not mentioned in the error or in Playwright's documentation on fixture patterns.

*Score: 11/15 · Included because: misleading error message, cross-project, non-obvious fix · Reservation: only hits when two Playwright fixtures coexist in a module*
