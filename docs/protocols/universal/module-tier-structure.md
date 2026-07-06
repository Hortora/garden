---
id: module-tier-structure
scope: universal
status: active
created: 2026-07-06
---

# Module Tier Structure

Three-tier rule for modular library design. Applies to any Quarkus extension or multi-module library.

## The Three Tiers

| Tier | Contents | Dependencies allowed |
|------|----------|---------------------|
| **Tier 1 — Pure-Java SPI** (`api/`) | Interfaces, records, enums, value types | Zero framework deps. CDI annotation JARs (`jakarta.inject-api`, `jakarta.enterprise.cdi-api`) and Mutiny (`io.smallrye.reactive:mutiny` as `provided`) are acceptable — both are inert without a container/runtime and every Quarkus consumer already has them. JPA and Quarkus runtime types remain excluded. |
| **Tier 2 — Core library** (`core/`) | Shared logic, routing strategies, utilities | Tier 1 deps + lightweight libraries. No JPA, no datasource requirements. |
| **Tier 3 — Full extension** (`runtime/`) | CDI beans, JPA entities, Flyway migrations, REST resources | Everything — Quarkus runtime, JPA, datasource config. |

## Rules

**SPI method signatures must not expose heavy external SDK types.** Consumers implement Tier 1 interfaces — their compile classpath should not force vendor SDKs.

**JPA entities must not co-locate with domain SPIs.** Placing entities in the SPI module forces all consumers to configure a datasource. Entities belong in Tier 3 or a dedicated `persistence-*` module.

**Persistence module split.** When a library needs both a domain SPI and a JPA implementation, split them: SPI in Tier 1, JPA impl in a separate `persistence-hibernate/` or `persistence-jpa/` module. Consumers that don't need persistence depend on Tier 1 only.

## SPI Default Patterns

Three patterns for SPI defaults, each with a different rationale:

| Pattern | When to use | Default impl location |
|---------|-------------|----------------------|
| **No-op default** | Operational SPIs where skipping the operation leaves the system functional (`WorkerProvisioner`, `CaseChannelProvider`) | Same pure-Java module as the SPI |
| **Populated default** | Vocabulary/registry SPIs where an empty implementation breaks routing immediately (`CapabilityRegistry`) | Same pure-Java module as the SPI |
| **No-op `@DefaultBean`** | Store SPIs that maintain persistent state (`CaseMemoryStore`, `WorkItemStore`) | Mock module (Tier 3) |

**Anti-pattern:** labelling an `InMemoryXxx` as `@DefaultBean`. `@DefaultBean` means no-op, not in-memory. The in-memory working implementation is `@Alternative @Priority(N)` in a separate `persistence-memory/` module, activated by classpath presence.

## References

- [`persistence-backend-cdi-priority`](persistence-backend-cdi-priority.md) — CDI priority ladder for persistence backends
- [`maven-submodule-folder-naming`](../casehub/maven-submodule-folder-naming.md) — folder naming convention
