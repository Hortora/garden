---
title: "Observability — Concepts"
domain: approaches
type: reference
score: 10
tags: [observability, logging, monitoring]
submitted: "2026-05-29"
---

# Observability — Concepts

**Domain tags:** `observability` `logging` `tracing` `metrics`  
**Last reviewed:** 2026-05-29

---

## What It Is

Observability is the ability to understand the internal state of a system
from its external outputs. It answers: what happened, when, where, and why —
without needing to reproduce the problem.

**With observability vs. without:**
- With correlation IDs: find all logs for a failing request in seconds
- Without correlation IDs: grep through gigabytes of logs manually for hours

---

## The Three Pillars

**Logs** — discrete events with context (what happened, when, where).
Human-readable records of system behaviour. Structured (JSON) logs are
machine-parseable and filterable by aggregators.

**Traces** — request flows across services (path through the system).
A trace is a collection of spans; each span is one operation with a
start and end time. Distributed tracing shows the full path of a request
as it moves through multiple services.

**Metrics** — aggregated measurements over time.
- **Counter** — monotonically increasing (total requests, total errors)
- **Histogram** — distribution of values (request duration, payload size)
- **Gauge** — current value, can go up or down (active connections, queue depth)

---

## Key Concepts

**Correlation ID** — a unique identifier generated at the request entry point
and propagated through all log entries and downstream calls. Allows filtering
all logs for a single request across multiple services.

**MDC (Mapped Diagnostic Context)** — a thread/context-local store that
automatically adds correlation fields to every log message within a scope.
Set once at entry; appears in all downstream logs without re-passing.

**Span** — a single named operation within a trace, with start time, end time,
and optional attributes. Spans nest to form the trace tree.

**OTLP (OpenTelemetry Protocol)** — the standard protocol for sending traces
and metrics to a collector (Jaeger, Zipkin, Tempo, Honeycomb, etc.).
OpenTelemetry (OTel) is the vendor-neutral standard for instrumentation.

**RED metrics** — the three most useful service-level metrics:
- **R**ate — requests per second
- **E**rror — proportion of failed requests
- **D**uration — latency distribution

**Sampling** — recording a fraction of traces (e.g., 10%) to control volume
while preserving statistical insight. Always-on for errors; sampled for
normal traffic.

---

## Why Observability Needs All Three

Logs alone: know something failed, but can't correlate across services.  
Traces alone: see the path, but lose detailed diagnostic context.  
Metrics alone: see aggregate trends, but can't drill into individual failures.

Together: metrics alert you, traces show you where, logs show you why.

---

## See Also

- [observability-patterns.md](observability-patterns.md) — implementation patterns, MDC setup, production checklist
- [frameworks/quarkus-flow.md](../frameworks/quarkus-flow.md) — Quarkus-specific observability config
