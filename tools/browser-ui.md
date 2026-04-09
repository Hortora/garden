# Browser UI Gotchas

---

## iframe swallows mousemove events when the cursor enters it during a drag

**ID:** GE-0129
**Stack:** Browser (all), JavaScript, any web app with a draggable splitter next to an iframe
**Symptom:** A draggable divider moves freely in one direction but freezes or snaps back when dragged in the opposite direction — specifically when the mouse crosses into an adjacent iframe panel.
**Context:** Split-pane UI with a draggable `<div>` between an iframe and a text panel. Dragging away from the iframe works; dragging toward it freezes the divider at the point where the cursor enters the iframe.

### What was tried (didn't work)
- Inspecting the `mousemove` handler — correctly attached to `document`
- Checking CSS for pointer-event blocking on the divider
- Assumed the resize calculation logic was wrong

### Root cause
When the mouse enters an iframe, the iframe's own browsing context captures all pointer events. The parent document's `mousemove` listener **stops firing** for as long as the cursor is inside the iframe. Dragging toward the iframe panel moves the cursor into the iframe partway through — freezing the divider at that position.

### Fix
Set `pointer-events: none` on the iframe at `mousedown` (drag start) and restore it at `mouseup` (drag end):

```javascript
divider.addEventListener('mousedown', () => {
  dragging = true;
  iframe.style.pointerEvents = 'none';  // prevent iframe capturing events
});
document.addEventListener('mouseup', () => {
  if (!dragging) return;
  dragging = false;
  iframe.style.pointerEvents = '';  // restore
});
```

### Why this is non-obvious
The symptom is directional — works one way, breaks the other — so it points to resize calculation logic rather than event capture. The connection between "mouse is inside iframe" and "parent document stops receiving events" is not documented in any drag tutorial. The fix is a one-liner but finding the cause requires understanding iframe event isolation.

*Score: 11/15 · Included because: directional symptom actively misleads about root cause, pointer-events fix non-obvious, common UI pattern · Reservation: specific to draggable-divider + iframe layout*

---

## `JSON.stringify()` in HTML onclick attribute silently truncates at the first inner double-quote

**ID:** GE-0130
**Stack:** Browser (all), HTML, JavaScript inline event handlers
**Symptom:** A button's onclick handler appears to fire but does nothing. The function is never called. No error in the console.
**Context:** A button rendered server-side with `onclick="deleteProject('${id}', ${JSON.stringify(name)})"`. Clicking does nothing.

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
The button looks correct in source. No error is thrown — the browser stops parsing the attribute at the inner quote and treats what follows as new attributes. The onclick appears registered but the expression is incomplete and never executes. Debugging shows the click event fires but the handler is empty.

*Score: 11/15 · Included because: silent breakage with no console error, common pattern in server-rendered HTML, data-* pattern is the non-obvious fix · Reservation: somewhat well-known in frontend circles*
