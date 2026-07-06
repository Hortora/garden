---
id: rest-adapter-module
scope: universal
status: active
created: 2026-07-06
refs:
  - casehubio/ledger#162
  - casehubio/engine#657
  - casehubio/work#292
---

# REST Adapter Module

## Rule

When a library exposes HTTP endpoints, the REST layer lives in a separate
opt-in module — never in the core library module. Consumers include it by
adding a dependency; consumers who only need the Java SPI pay no JAX-RS
coupling cost.

```
my-library/
  api/              ← SPIs, domain types (Tier 1 — no framework deps)
  runtime/           ← services, entities (Tier 2/3 — no JAX-RS)
  rest/              ← JAX-RS resources, DTOs, exception mappers (opt-in)
```

The REST module is a plain JAR with CDI beans that carry JAX-RS annotations.
It is not a Quarkus extension — no deployment module is needed. Quarkus
auto-discovers the resources via Jandex indexing.

## Rationale

REST is a transport adapter, not part of the domain. Embedding it in the
core module forces every consumer to accept auto-registered endpoints,
pulls JAX-RS into the dependency graph, and makes suppression awkward
(build-time exclusions, `@IfBuildProperty` gates). A separate module
inverts the default: REST is opt-in, not opt-out.

This is Ports & Adapters (Hexagonal Architecture) applied to HTTP: the
library's SPI is the port; the REST module is one possible adapter.

## What belongs in the REST module

- **JAX-RS resource classes** — `@Path`, `@GET`, `@POST`, etc.
- **DTOs** — request/response representations, decoupled from domain entities.
- **Exception mappers** — `@Provider` classes translating domain exceptions to HTTP responses.
- **OpenAPI annotations** — `@Tag`, `@Operation`, `@APIResponse` on resource methods.

## What stays in the core module

- SPIs, domain types, entities, repositories, services, CDI events — everything
  that works without an HTTP boundary.

## Conventions

### Dependency direction

The REST module depends on the core library. The core library never
references the REST module.

```xml
<dependency>
  <groupId>io.example</groupId>
  <artifactId>my-library</artifactId>
  <version>${project.version}</version>
</dependency>
```

### Path prefix

Each REST module owns a path namespace. Use a consistent prefix across
modules so composed applications have a predictable URL space.

### DTOs vs domain types

REST resources return DTOs (records), not domain entities. The DTO is the
API contract; the domain entity is an implementation detail. This allows
the domain model to evolve without breaking HTTP clients.

### Versioning

The REST module versions alongside the core library — same multi-module
build, same release. Use `${project.version}` to keep them locked.

## Composition pattern

A deployable application composes libraries and their REST modules:

```xml
<dependency>my-engine</dependency>
<dependency>my-engine-rest</dependency>      <!-- opt-in -->
<dependency>my-ledger</dependency>
<dependency>my-ledger-rest</dependency>      <!-- opt-in -->
<dependency>my-work</dependency>
<!-- skip work-rest — this app writes its own domain-specific endpoints -->
```

A reference deployment (starter app, scaffold) is simply the full
composition: all libraries + all REST modules + persistence + config.
It is the canonical runnable artifact, not the only place REST exists.

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| REST in core runtime | Auto-registers on every consumer; can't suppress without build-time exclusion | Separate module |
| Consumer reimplements generic REST | Duplicated boilerplate, inconsistent API surfaces, no shared tooling | Include the library's REST module |
| Scaffold as sole REST provider | Non-scaffold deployments get zero REST for the library | REST module in the library build; scaffold depends on it |
| DTOs that expose JPA entities directly | Hibernate proxies, lazy-load exceptions, schema leaks | Dedicated DTO records in the REST module |

## Relationship to module-tier-structure

This protocol extends the three-tier module structure
(`pure-Java SPI / core library / full extension`). The REST module is a
fourth tier — a transport adapter that depends on Tier 2/3 but is never
required by it. The tiers remain:

1. **Tier 1** — `api/` (pure Java, no framework)
2. **Tier 2/3** — `runtime/` (services, JPA, CDI)
3. **Adapter** — `rest/` (JAX-RS, opt-in)
4. **Adapter** — other transport adapters (gRPC, MCP, CLI) follow the same pattern
