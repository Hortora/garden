---
id: routing-strategy-convention
scope: platform
status: active
created: 2026-07-04
refs:
  - casehubio/engine#634
---

# Routing Strategy Convention

## Rule

Per-case or per-binding selectable strategies extend `NamedStrategy` (`io.casehub.platform.api.routing`), declare a stable `id()`, ship a `@DefaultBean` no-op or sensible-default implementation, and resolve via `StrategyResolver`.

Selection models that bypass this convention are not to be used for new routing strategies:
- CDI `@Priority` override
- `@Named` qualifier
- Config property switch
- Direct `Instance<>` iteration

## Non-Members

These mechanisms are intentionally excluded from the convention — they serve different patterns:

- `ActionRiskClassifier` — chain composition (most-restrictive-wins), not per-case selection
- `@DefaultBean`-only SPIs — single-bean replacement (e.g. `ExclusionPolicy`, `CapabilityHealth`), not per-case selectable
- `ContextDiffStrategy` — deployment-level config switch, stays as-is
- Access control policies — determines what CAN flow, not where
- Data providers — feed INTO routing strategies, not routing decisions themselves
- Delivery infrastructure — direct ID lookup, caller specifies target
