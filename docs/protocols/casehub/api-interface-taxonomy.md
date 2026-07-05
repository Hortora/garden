---
id: api-interface-taxonomy
scope: platform
status: active
created: 2026-07-05
refs:
  - casehubio/qhorus#316
  - casehubio/qhorus#315
---

# API Interface Taxonomy

## Rule

The `api/` module of a Quarkus extension exposes four categories of interface, distinguished by the consumer's relationship to each:

| Category | Package | Consumer relationship | Examples (qhorus) |
|----------|---------|----------------------|-------------------|
| **Store** | `api/store/` | Consumer **provides** JPA implementation, also calls for reads | `ChannelStore`, `CommitmentStore`, `MessageStore` |
| **SPI** | `api/spi/` | Consumer **provides** policy/extension implementation | `CommitmentAttestationPolicy`, `ObligorTrustPolicy` |
| **Gateway** | `api/gateway/` | Consumer **provides** integration backend | `AgentChannelBackend`, `MessageObserver`, `InboundNormaliser` |
| **Service facade** | `api/<domain>/` | Consumer **calls** (never implements) | `ChannelManager`, `MessageDispatcher`, `ReactiveChannelManager` |

Stores, SPIs, and gateways are **provided by** consumers. Service facades are **consumed by** consumers. This inverted relationship drives the placement decision.

Service facades colocate with domain types in `api/<domain>/` (e.g. `api/channel/ChannelManager.java` alongside `api/channel/Channel.java`). They do not go in `api/spi/` — that package signals "implement me", which is the wrong contract for a facade.

## Scope

This taxonomy is a CaseHub convention, specifically realised in qhorus. Other foundation repos have different `api/` structures appropriate to their interface mix — casehub-work-api uses a flat layout with `spi/` as the only sub-package; casehub-engine-common uses `spi/`, `qualifier/`, and `internal/`. The full four-category structure applies to repos that develop all four kinds of interfaces.

## Tier model integration

The `api/` module IS Tier 1 of the three-tier module structure (pure-Java SPI / core library / full extension). All four interface categories are Tier 1 contracts — no JPA, no Quarkus runtime dependencies in the interface signature:

- Stores, SPIs, gateways → Tier 1 contracts that consumers **implement**
- Service facades → Tier 1 contracts that consumers **call**

## Per-category rules

### Stores (`api/store/`)

- Data access contracts — CRUD operations over domain entities.
- Blocking and reactive pairs: `ChannelStore` + `ReactiveChannelStore`.
- JPA implementations live in `runtime/` (they depend on Panache/Hibernate) — always present since the extension provides them.
- Working `@Alternative @Priority(1)` in-memory implementations in `persistence-memory/` — activated by classpath presence for consumer test isolation without a datasource.

### SPIs (`api/spi/`)

- Extension points where consumers replace default behaviour with custom logic.
- Three default patterns: no-op (operational SPIs), populated (vocabulary/registry SPIs), no-op `@DefaultBean` in mock module (store SPIs).
- Must be implementable without depending on `runtime/` — pure-Java signatures only.
- `@DefaultBean` implementations go in `runtime/` when they have JPA or config deps; in `api/spi/` itself when trivially pure-Java.

### Gateways (`api/gateway/`)

- Integration contracts for external systems or cross-cutting observers.
- Consumer provides the implementation to bridge their infrastructure into the runtime.
- Sub-interfaces specialize the contract: `AgentChannelBackend`, `HumanParticipatingChannelBackend`, `HumanObserverChannelBackend` all extend `ChannelBackend`.
- Event types (`MessageReceivedEvent`, `ChannelInitialisedEvent`) colocate here — they define the integration surface.

### Service facades (`api/<domain>/`)

- Consumer-facing interfaces that consumers call, never implement.
- The runtime module provides the `@ApplicationScoped` implementation.
- Colocated with domain types, records, and enums in the same package.
- Blocking and reactive pairs: `ChannelManager` + `ReactiveChannelManager`.
- Exist to give consumers a stable API contract independent of runtime internals.

## Decision flowchart

When adding a new interface to `api/`:

1. **Does the consumer call it or implement it?**
   - Calls it → **service facade** → `api/<domain>/`
   - Implements it → continue to 2

2. **What does the implementation do?**
   - Persists/retrieves data → **store** → `api/store/`
   - Bridges an external system or observes events → **gateway** → `api/gateway/`
   - Replaces a policy or behavioural extension point → **SPI** → `api/spi/`

3. **Ambiguity: store vs gateway**
   - Needs a datasource → store
   - Connects to an external service or reacts to runtime events → gateway

4. **Ambiguity: SPI vs gateway**
   - Behavioural extension (policy, computation, fold logic) → **SPI** → `api/spi/`
   - Infrastructure integration (external system bridge, event observation) → **gateway** → `api/gateway/`

   Multiplicity is a secondary consideration — both SPIs and gateways can support single or multiple instances. `RenderableProjection` has multiple coexisting implementations selected by name (`projectionName()`), yet it is an SPI because it provides consumer-owned fold logic. `ChannelBackend` has multiple coexisting implementations selected by name (`backendId()`), yet it is a gateway because it bridges external messaging infrastructure.

## Domain types and non-interface packages

Records, enums, and value objects are not a category — they are the vocabulary the four categories operate on. Three placement patterns:

1. **Colocated with a service facade** — domain types live alongside the facade in `api/<domain>/`. Examples: `Channel` in `api/channel/` with `ChannelManager`.
2. **Standalone domain package** — domain types whose sub-domain is significant but which have no facade or SPI of their own. Examples: `api/data/`, `api/instance/`. Their associated stores live in `api/store/`.
3. **Domain-scoped sub-package with its own SPI** — a sub-domain package that combines domain types AND an SPI interface tightly coupled to those types. Example: `api/watchdog/` contains the `Watchdog` record, alert context types, AND `WatchdogAlertRouter` (an SPI). Domain-scoped SPIs colocate with their domain package when the SPI's method signatures are tightly coupled to the domain types; cross-cutting SPIs go in `api/spi/`.

CDI qualifiers and framework annotations (e.g. `@CrossTenant` in `api/qualifier/`) are infrastructure, not domain types or interface categories. They may exist in `api/` as needed.
