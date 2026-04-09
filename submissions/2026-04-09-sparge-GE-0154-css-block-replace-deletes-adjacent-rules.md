**Type:** gotcha
**Submission ID:** GE-0154
**Date:** 2026-04-09
**Project:** sparge
**Stack:** CSS, bulk restyling, find-and-replace

## Replacing a CSS rule block silently deletes adjacent rules not included in the replacement

**Symptom:** After a task that replaced the `#tabbar` CSS rule with an updated version, the tab bar became permanently invisible. No CSS error, no JS error. The JS that toggles `.visible` appeared to run normally.

**Context:** Large CSS restyling effort with 12 tasks, each replacing specific rule blocks in a single `<style>` tag. Task 8 replaced `#tabbar { ... }` but the adjacent `#tabbar.visible { display:flex; }` rule wasn't included in the replacement text, so it was silently deleted.

**What was tried:** The task spec listed `#tabbar` and `.tab` rules — `.visible` wasn't explicitly called out. The implementer replaced the listed rules and moved on.

**Root cause:** When replacing a CSS block via find/replace or Edit tool, only the exact text matched is replaced. Adjacent rules (even immediately following) are not automatically carried over. If the adjacent rule wasn't in the "replace with" content, it simply disappears. The JS (`toggleLayout()` adding/removing `.visible`) continued to function, so there was no runtime error — the class was toggled, but the CSS rule that responded to it was gone.

**Fix:** When replacing any CSS rule, read the surrounding context first and explicitly verify that all adjacent rules for the same selector are preserved or intentionally removed:

```css
/* Make sure these BOTH appear in the replacement */
#tabbar { ... display:none; }
#tabbar.visible { display:flex; }  /* ← easy to miss when replacing the base rule */
```

Code quality review caught this by checking functional regression: "the only way the tabbar becomes visible is when JS adds `.visible`".

**Why non-obvious:** The symptom (tab bar never shows) doesn't point to CSS — it looks like a JS bug. The JS runs correctly. The failure is in a rule that existed but was silently dropped during an unrelated edit to the base rule. Most CSS validation tools don't flag a missing `.visible` rule as an error.

**Scanned existing entries:** None closely matching (no existing "CSS block replacement" gotcha)

*Score: 13/15 · Included because: silent functional regression, symptom misleads to JS, easy to hit during any bulk CSS restyling · Reservation: somewhat obvious in hindsight, but easy to miss under task pressure*

**Suggested target:** `tools/css.md` (or `tools/browser-ui.md`)
