# Framework Registry — Design Spec

**Status:** Proposed  
**Date:** 2026-05-27  
**Layer:** Hortora extension — sits above the knowledge garden

---

## Problem

The knowledge garden captures hard-won gotchas and techniques from real work.
What it doesn't have is a starting point for work that hasn't happened yet.

When incorporating a new framework or technology:
- An LLM starts from scratch — web searches cold, discovers things at random
- The garden has scattered entries for a technology but no aggregation point
- There's no curated map of "here's where the important docs are"
- Frameworks that *could* be used aren't visible until someone already knows them

The result: incorporating a new technology into an application is slower and less
reliable than it needs to be. The LLM rediscovers what could have been pre-indexed.

---

## What the Framework Registry Is

A curated catalogue of frameworks and technologies that an LLM can query
**before** starting work, rather than searching cold. Each entry is a hub file
that:

1. **Explains what the framework is** — one paragraph, LLM-optimised
2. **Tags it by domain** — the problem it solves, not what it is
3. **Indexes key documentation URLs** — specific sections, not just homepages
4. **Links to existing garden entries** — gotchas and techniques already captured
5. **Captures integration patterns** — how-tos and approaches for common tasks
6. **Registers future capability** — frameworks can be indexed before they're needed

The registry doesn't replace the garden. Forage still captures individual gotchas
into GE-* entries during real work. The registry provides the aggregation layer
that the garden lacks — a single place to start when a framework is relevant.

---

## Domain Tags

Discovery is by domain — the **problem** being solved, not the technology name.
An LLM can say "I need workflow capability" and find matching frameworks without
already knowing their names.

Proposed initial tag taxonomy:

| Tag | Problem domain |
|-----|---------------|
| `workflow` | Orchestrating multi-step processes, state machines |
| `messaging` | Async communication, event streaming, queues |
| `integration` | Connecting disparate systems, ETL, EIP patterns |
| `observability` | Logging, tracing, metrics, alerting |
| `auth` | Authentication, authorisation, identity |
| `persistence` | Databases, ORM, caching |
| `api` | REST, GraphQL, gRPC, OpenAPI |
| `testing` | Test frameworks, mocking, contract testing |
| `build` | Build tools, packaging, CI/CD |
| `ai` | LLM integration, agents, embeddings |

A framework can carry multiple tags. Apache Camel carries `integration`,
`messaging`, and `workflow`.

---

## Structure

```
~/.hortora/
  docs/
    framework-registry.md    ← this file (the spec)
  garden/
    frameworks/              ← the registry entries
      quarkus-flow.md
      apache-camel.md
      kafka.md
      ...
    README.md                ← existing garden orientation
    GARDEN.md                ← existing entry index
    quarkus/                 ← existing GE-* entries
    casehub-engine/
    ...
```

Registry entries live in `garden/frameworks/` so they sit alongside the existing
garden and can cross-reference GE-* entries naturally.

---

## Entry Format

Each framework gets one `.md` file. Structured for LLM consumption — dense,
not prose.

```markdown
# <Framework Name>

**Domain tags:** `workflow` `messaging`  
**Version tracked:** <version or "latest">  
**Last reviewed:** YYYY-MM-DD

## What It Is

One paragraph. What the framework does, what problem it solves, when you'd
reach for it over alternatives. Written for an LLM starting from zero.

## When to Use

- Use when: [specific condition]
- Use when: [specific condition]
- Don't use when: [specific condition — when another framework fits better]

## Key Documentation

| Resource | URL | What's there |
|----------|-----|-------------|
| Getting Started | <url> | First app in 10 minutes |
| API Reference | <url> | Full class/method docs |
| YAML Schema | <url> | Configuration reference |
| Examples | <url> | Working code samples |
| Migration Guide | <url> | Version-to-version changes |

## Core Concepts

The vocabulary an LLM needs to ask good questions and read the docs:

- **<Term>** — definition
- **<Term>** — definition

## Integration Patterns

Common tasks and how to approach them. Not full tutorials — enough to know
the right direction and avoid the wrong one.

### <Pattern name>

Brief description. Key classes/annotations involved. Link to docs section.

## Garden Entries

Gotchas and techniques already captured for this framework:

- [GE-XXXX Title](../category/GE-XXXX.md) — one-line summary
- [GE-XXXX Title](../category/GE-XXXX.md) — one-line summary

## Known Gaps

Things not yet captured — areas where the docs are thin or the gotchas
haven't been hit yet. Useful for knowing what to watch for.

- [ ] <Area not yet documented>
```

---

## Example: quarkus-flow Entry (Skeleton)

```markdown
# Quarkus Flow

**Domain tags:** `workflow` `ai`  
**Version tracked:** 0.x (pre-GA)  
**Last reviewed:** 2026-05-27

## What It Is

quarkus-flow is Quarkus's implementation of the CNCF Serverless Workflow
specification. Workflows are defined as CDI beans extending `Flow`, using
FuncDSL or YAML. Targets stateful, multi-step orchestration with human-in-
the-loop support, AI agent integration, and reactive execution on Vert.x.

## When to Use

- Use when: building multi-step processes with explicit state and branching
- Use when: integrating AI agents into structured workflows
- Use when: needing HITL (human-in-the-loop) pauses with external signals
- Don't use when: simple async fire-and-forget (use Quarkus @Asynchronous)
- Don't use when: pure event streaming (use Quarkus Messaging / Kafka)

## Key Documentation

| Resource | URL | What's there |
|----------|-----|-------------|
| Getting Started | https://quarkiverse.io/quarkus-flow | Overview |
| FuncDSL Reference | <url> | Java DSL API |
| YAML Schema | <url> | Workflow YAML spec |
| CNCF Spec | https://serverlessworkflow.io | Underlying spec |

## Core Concepts

- **Flow** — base class; all workflows extend this, annotated @ApplicationScoped
- **FuncDSL** — Java fluent API for defining workflow tasks inline
- **descriptor()** — the method override where the workflow graph is defined
- **HITL** — Human-in-the-loop; workflow pauses until an external signal resumes it
- **emit / listen** — event-based task coordination within a workflow

## Integration Patterns

### Basic workflow structure
...

### HITL pause and resume
...

## Garden Entries

- [GE-20260414-10d4da CNCF CallableTaskBuilder.accept() cannot distinguish custom callable names](../casehub-engine/GE-20260414-10d4da.md)

## Known Gaps

- [ ] Error handling and compensation patterns
- [ ] Testing workflows with @QuarkusTest
- [ ] Performance characteristics at scale
```

---

## How LLMs Use the Registry

### Discovery flow

```
"I need to add workflow capability to this application"

1. List frameworks/               → see quarkus-flow.md, temporal.md, etc.
2. Read domain tags from each    → find ones tagged `workflow`
3. Read "What It Is" + "When to Use" for candidates
4. Present options to user
5. User picks one
6. Load full entry + fetch key doc URLs
7. Proceed with implementation
```

### Pre-registered capability

Apache Camel can be registered under `integration` before it's ever used.
When a future application needs enterprise integration patterns, the LLM finds
it already indexed — no cold search required. The entry might have no garden
entries yet and incomplete integration patterns, but the core navigation is there.

### Feeding the registry from the garden

When forage captures a new GE-* entry for a framework that has a hub file,
the hub file's "Garden Entries" section should be updated to link to it. This
is a lightweight maintenance step — the hub file grows richer over time as
real work surfaces new gotchas.

---

## Relationship to Existing Hortora Layers

| Layer | Captures | When |
|-------|----------|------|
| Garden (GE-* entries) | Individual gotchas and techniques from real work | Post-hoc, during/after a session |
| Framework registry | Framework overview, docs index, patterns, garden aggregation | Pre-work, proactively maintained |

The registry doesn't compete with the garden — it links to it. A framework
hub file with 12 garden entry links is more valuable than one with 0, and it
gets richer automatically as forage does its job.

---

## Maintenance

| Task | Trigger | Who |
|------|---------|-----|
| Create hub file | Deciding to use a new framework | Developer, before first use |
| Pre-register a framework | Identifying a framework that *might* be needed | Developer, proactively |
| Update garden entry links | After forage CAPTURE adds a new GE-* entry | Developer or forage skill |
| Update key doc URLs | Framework releases breaking changes to docs | Developer, when noticed |
| Mark deprecated | Framework abandoned or replaced | Developer |

Hub files don't need frequent updates. The garden handles the living knowledge;
the registry handles the stable navigation layer.

---

## Open Questions

1. **Should the forage skill automatically suggest updating the hub file** when
   capturing a GE-* entry for a framework that has one?

2. **Should there be a registry index** (like GARDEN.md) listing all hub files
   with their domain tags for fast discovery? Or is `ls frameworks/` sufficient?

3. **Scope of integration patterns**: how deep should these go? Skeleton enough
   to orient, or detailed enough to implement from? The garden handles detail;
   the registry probably stays at skeleton level.

4. **Cross-project sharing**: if this becomes valuable, should the registry be
   shareable — a community-maintained quarkus-flow hub file, for example?
   Probably out of scope for now but worth noting.
