---
id: custom-event-shadow-dom
title: "CustomEvents crossing shadow DOM need both bubbles and composed"
type: rule
scope: universal
applies_to: "any Web Component dispatching CustomEvents from shadow DOM"
severity: important
refs: []
violation_hint: "CustomEvent dispatched from shadow DOM with only bubbles:true or only composed:true — event will not reach ancestors outside the shadow root"
created: 2026-07-05
---

CustomEvents intended to cross shadow DOM boundaries must set both
`bubbles: true` and `composed: true`.

| Configuration | Behaviour |
|--------------|-----------|
| `bubbles: false, composed: false` | Event stays on the target element |
| `bubbles: true, composed: false` | Propagates up the DOM but stops at the shadow root boundary |
| `bubbles: false, composed: true` | Crosses the shadow boundary but does not propagate to ancestors |
| `bubbles: true, composed: true` | Crosses shadow boundaries AND propagates up the full DOM tree |

Only the last combination delivers the event to listeners on ancestor elements
outside the shadow root.

## Public vs internal events

Set `composed: true` when the event is part of the component's **public API** —
consumers listen for it on or above the component.

Omit `composed` (or set it to `false`) when the event coordinates **internal
sub-elements** within the same shadow root. Leaking internal events to the
outer DOM creates coupling — consumers start depending on implementation details.

## Pattern

```typescript
// Public event — crosses shadow DOM, reaches ancestors
target.dispatchEvent(new CustomEvent('my-public-event', {
  bubbles: true,
  composed: true,
  detail: payload,
}));

// Internal event — stays within shadow root
target.dispatchEvent(new CustomEvent('internal-sync', {
  bubbles: true,
  composed: false,
  detail: state,
}));
```
