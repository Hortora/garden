# CSS Gotchas and Techniques

---

## CSS `var()` in an iframe `<style>` tag silently produces no output

**ID:** GE-0153
**Stack:** CSS Custom Properties, browser iframes, HTML

**Symptom:** JS writes a `<style>` tag into an iframe's `contentDocument` using `var(--error)` to set an outline colour. The outline never appears — no error, no warning, no fallback colour.

**Context:** Any time JS dynamically injects styles into a same-origin iframe's document (e.g., `styleTag.textContent = '... outline: 3px solid var(--error) ...'`). The CSS custom properties are defined on the host page's `:root`, not the iframe's.

### What was tried

The CSS looked syntactically correct and the host page rendered correctly with `var(--error)`. It was not obvious the style tag was being injected into a separate document.

### Root cause

CSS custom properties are scoped to a browsing context. An iframe's `contentDocument` is a separate browsing context with its own cascade root. Custom properties defined on the host page's `:root` are not inherited across frame boundaries. The computed value of `var(--error)` inside the iframe is the CSS initial value (empty/invalid), so the declaration is silently dropped.

### Fix

Use the resolved literal hex value in styles injected into iframes:

```javascript
// WRONG — var() silently fails across frame boundary
styleTag.textContent = `${selector} { outline: 3px solid var(--error) !important; }`;

// CORRECT — use the literal hex value
styleTag.textContent = `${selector} { outline: 3px solid #8a2a2a !important; }`;
```

### Why non-obvious

CSS custom properties cascade normally within the host page, so they're expected to work everywhere. The fact that they don't cross browsing context boundaries is a spec detail that isn't prominently documented. The failure is completely silent — no console error, no fallback, no visual indication that the `var()` failed.

**See also:** GE-0084 (headless Playwright iframe caching), GE-0087 (assert iframe.src changes after save)

*Score: 15/15 · Included because: silent failure, non-obvious frame boundary mechanic, breadth applies to any project injecting styles into iframes · Reservation: none*

---

## Replacing a CSS rule block silently deletes adjacent rules not included in the replacement

**ID:** GE-0154
**Stack:** CSS, bulk restyling, find-and-replace

**Symptom:** After a task that replaced the `#tabbar` CSS rule with an updated version, the tab bar became permanently invisible. No CSS error, no JS error. The JS that toggles `.visible` appeared to run normally.

**Context:** Large CSS restyling effort with multiple tasks, each replacing specific rule blocks in a single `<style>` tag. One task replaced `#tabbar { ... }` but the adjacent `#tabbar.visible { display:flex; }` rule wasn't included in the replacement text, so it was silently deleted.

### What was tried

The task spec listed `#tabbar` and `.tab` rules — `.visible` wasn't explicitly called out. The implementer replaced the listed rules and moved on.

### Root cause

When replacing a CSS block via find/replace or Edit tool, only the exact text matched is replaced. Adjacent rules (even immediately following) are not automatically carried over. If the adjacent rule wasn't in the "replace with" content, it simply disappears. The JS (`toggleLayout()` adding/removing `.visible`) continued to function, so there was no runtime error — the class was toggled, but the CSS rule that responded to it was gone.

### Fix

When replacing any CSS rule, read the surrounding context first and explicitly verify that all adjacent rules for the same selector are preserved or intentionally removed:

```css
/* Make sure these BOTH appear in the replacement */
#tabbar { ... display:none; }
#tabbar.visible { display:flex; }  /* ← easy to miss when replacing the base rule */
```

Code review caught this by checking functional regression: "the only way the tabbar becomes visible is when JS adds `.visible`".

### Why non-obvious

The symptom (tab bar never shows) doesn't point to CSS — it looks like a JS bug. The JS runs correctly. The failure is in a rule that existed but was silently dropped during an unrelated edit to the base rule. Most CSS validation tools don't flag a missing `.visible` rule as an error.

*Score: 13/15 · Included because: silent functional regression, symptom misleads to JS, easy to hit during any bulk CSS restyling · Reservation: somewhat obvious in hindsight, but easy to miss under task pressure*

---
