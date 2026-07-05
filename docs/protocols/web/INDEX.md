# Web Protocols

Universal conventions for Web Component and browser-side development.
Not CaseHub-specific — these apply to any project using these technologies.

## Protocols

| File | Rule Summary | Applies To |
|------|-------------|------------|
| [lit-immutable-collections.md](lit-immutable-collections.md) | Replace reactive collections on every mutation — never mutate in place | Any Lit project |
| [custom-event-shadow-dom.md](custom-event-shadow-dom.md) | CustomEvents crossing shadow DOM need both `bubbles: true` and `composed: true` | Any Web Component with shadow DOM |
