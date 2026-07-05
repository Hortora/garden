# CaseHub Foundation Protocols

Platform-level conventions and rules for the casehubio ecosystem.

## Protocols

- [API Interface Taxonomy](api-interface-taxonomy.md) — Four categories of `api/` interfaces (store, SPI, gateway, service facade) with placement rules and decision flowchart
- [Routing Strategy Convention](routing-strategy-convention.md) — Per-case selectable strategies extend `NamedStrategy`, declare `id()`, ship `@DefaultBean` default, resolve via `StrategyResolver`

## Other Namespaces

- [Web Protocols](../web/INDEX.md) — universal Web Component conventions (Lit, shadow DOM)
