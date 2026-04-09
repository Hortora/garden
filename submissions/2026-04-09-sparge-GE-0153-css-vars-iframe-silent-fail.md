**Type:** gotcha
**Submission ID:** GE-0153
**Date:** 2026-04-09
**Project:** sparge
**Stack:** CSS Custom Properties, browser iframes, HTML

## CSS `var()` in an iframe `<style>` tag silently produces no output

**Symptom:** JS writes a `<style>` tag into an iframe's `contentDocument` using `var(--error)` to set an outline colour. The outline never appears — no error, no warning, no fallback colour.

**Context:** Any time JS dynamically injects styles into a same-origin iframe's document (e.g., `styleTag.textContent = '... outline: 3px solid var(--error) ...'`). The CSS custom properties are defined on the host page's `:root`, not the iframe's.

**What was tried:** The CSS looked syntactically correct and the host page rendered correctly with `var(--error)`. It was not obvious the style tag was being injected into a separate document.

**Root cause:** CSS custom properties are scoped to a browsing context. An iframe's `contentDocument` is a separate browsing context with its own cascade root. Custom properties defined on the host page's `:root` are not inherited across frame boundaries. The computed value of `var(--error)` inside the iframe is the CSS initial value (empty/invalid), so the declaration is silently dropped.

**Fix:** Use the resolved literal hex value in styles injected into iframes:

```javascript
// WRONG — var() silently fails across frame boundary
styleTag.textContent = `${selector} { outline: 3px solid var(--error) !important; }`;

// CORRECT — use the literal hex value
styleTag.textContent = `${selector} { outline: 3px solid #8a2a2a !important; }`;
```

**Why non-obvious:** CSS custom properties cascade normally within the host page, so they're expected to work everywhere. The fact that they don't cross browsing context boundaries is a spec detail that isn't prominently documented. The failure is completely silent — no console error, no fallback, no visual indication that the var() failed.

**Scanned existing entries:** GE-0084, GE-0087 (both iframe-related but about Playwright/cache, not CSS vars)

*Score: 15/15 · Included because: silent failure, non-obvious frame boundary mechanic, breadth applies to any project injecting styles into iframes · Reservation: none*

**Suggested target:** `tools/browser-ui.md` (or `tools/css.md` if that file exists)
