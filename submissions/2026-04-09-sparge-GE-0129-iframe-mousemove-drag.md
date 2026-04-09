# Garden Submission

**Date:** 2026-04-09
**Submission ID:** GE-0129
**Type:** gotcha
**Source project:** sparge (mdproctor.github.io blog migrator)
**Session context:** Fixing split-pane divider drag — dragging left froze while dragging right worked fine
**Suggested target:** `tools/browser-ui.md` (new file — header: `# Browser UI Gotchas and Techniques`)

---

## iframe swallows mousemove events when the cursor enters it during a drag

**Stack:** Browser (all), JavaScript, any web app with a draggable splitter next to an iframe
**Symptom:** A draggable divider moves freely in one direction but freezes or snaps back when dragged in the opposite direction — specifically when the mouse crosses into an adjacent iframe panel.
**Context:** Split-pane UI with a draggable `<div id="divider">` between an iframe (HTML preview) and a text panel (MD preview). Dragging right worked fine; dragging left froze.

### What was tried (didn't work)
- Inspecting the `mousemove` handler — it was correctly attached to `document`
- Checking for CSS issues blocking pointer events on the divider itself
- Assumed the problem was in the resize calculation logic

### Root cause
When the mouse enters an iframe, the iframe's own browsing context captures all pointer events. The parent document's `mousemove` listener **stops firing** for as long as the cursor is inside the iframe. Since dragging left moved the divider toward the iframe panel, the cursor entered the iframe partway through the drag — freezing the divider at that position.

### Fix
Set `pointer-events: none` on the iframe at `mousedown` (drag start) and restore it at `mouseup` (drag end):

```javascript
$('divider').addEventListener('mousedown', () => {
  dragging = true;
  $('orig-frame').style.pointerEvents = 'none';  // prevent iframe capturing events
});
document.addEventListener('mouseup', () => {
  if (!dragging) return;
  dragging = false;
  $('orig-frame').style.pointerEvents = '';  // restore
});
```

### Why this is non-obvious
The symptom is directional — works one way, breaks the other — so it points to resize calculation logic rather than event capture. The connection between "mouse is inside iframe" and "parent document stops receiving events" is not documented in any drag tutorial. The fix is a one-liner but finding the cause requires understanding iframe event isolation.
