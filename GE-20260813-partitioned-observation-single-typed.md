---
id: GE-20260813-partitioned-observation-single-typed
title: PartitionedObservationService is single-typed — cannot hold multiple event types
category: gotcha
domain: casehub-blocks
tags: [observation, summarisation, type-system]
created: 2026-08-13
freshness: 2026-08-13
---

`PartitionedObservationService<E, K>` is parameterized on a single event type `E` with one `EventLevel`. It cannot hold 5 different types (PriceTick, OHLCV, TrendSummary, RegimeAssessment, SessionNarrative) across 5 levels in one instance. For multi-level observation caching, build a custom wrapper (e.g., `FsiObservationCache`) with per-type `ConcurrentHashMap`s. The `VisibilityPolicy` concept can be realized via a separate policy class without using the platform's `PartitionedObservationService` directly.
