# Garden Submission

**Date:** 2026-04-09
**Submission ID:** GE-0130
**Type:** gotcha
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Project delete button did nothing — onClick handler was silently broken
**Suggested target:** `tools/browser-ui.md`

---

## JSON.stringify() in HTML onclick attribute silently truncates at the first inner double-quote

**Stack:** Browser (all), HTML, JavaScript inline event handlers
**Symptom:** A button's onclick handler appears to fire but does nothing. The function is never called. No error in the console.
**Context:** A project card rendered server-side with an inline onclick: `onclick="deleteProject('${id}', ${JSON.stringify(name)})"`. Clicking did nothing.

### Root cause
`JSON.stringify("My Project")` produces `"My Project"` — a string with surrounding double-quotes. When embedded inside an HTML attribute delimited by double-quotes:

```html
onclick="deleteProject('my-id', "My Project")"
```

The HTML parser terminates the attribute value at the **first inner `"`**, leaving `onclick="deleteProject('my-id', "`. The browser sees a broken, incomplete expression and silently discards it.

### Fix
Never embed `JSON.stringify()` output directly in HTML attributes. Use `data-*` attributes instead:

```html
<!-- Wrong -->
<button onclick="deleteProject('${id}', ${JSON.stringify(name)})">Delete</button>

<!-- Correct -->
<button data-id="${id}" data-name="${esc(name)}"
        onclick="deleteProject(this.dataset.id, this.dataset.name)">Delete</button>
```

### Why this is non-obvious
The button looks correct in the source. No error is thrown — the browser simply stops parsing the attribute at the inner quote and treats what follows as new attributes. The onclick appears registered but the expression is incomplete and never executes. Debugging shows the click event fires but the handler is empty.
