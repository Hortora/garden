---
id: lit-immutable-collections
title: "Replace Lit reactive collections on every mutation — never mutate in place"
type: rule
scope: universal
applies_to: "any Lit @state() or @property() holding Set, Map, or Array"
severity: important
refs: []
garden_ref: GE-20260705-7c80f2
violation_hint: "Lit reactive property mutated in place with .add()/.delete()/.push() instead of replaced with a new collection"
created: 2026-07-05
---

Reactive properties (`@state()`, `@property()`) holding mutable collections
(Set, Map, Array) must be replaced on every mutation, never mutated in place.

Lit uses strict reference equality (`===`) to detect property changes. Mutating
a collection in place (`.add()`, `.delete()`, `.push()`, `.splice()`) keeps the
same object reference. Lit sees "same reference → no change" and skips re-render.

This also affects child components. When a parent passes a collection to a child
via property binding (`.items=${this.mySet}`), Lit compares the property value
with `===`. Same reference → child skips re-render too.

## Wrong

```typescript
this.items.add(value);
this.requestUpdate(); // forces THIS component, but children still skip
```

## Right

```typescript
// Set
this.items = new Set([...this.items, value]);

// Map
this.lookup = new Map([...this.lookup, [key, value]]);

// Array
this.list = [...this.list, item];
```

## Why `requestUpdate()` is not a workaround

`requestUpdate()` forces the calling component to re-render. But when Lit
re-renders the parent and evaluates `.items=${this.mySet}`, it still compares
with `===`. Same reference → child property unchanged → child skips re-render.
The only fix is a new reference.

## Scope

This applies to any mutable reference type. Primitives (boolean, string, number)
are not affected — reassignment always creates a new value.
