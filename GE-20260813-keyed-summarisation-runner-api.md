---
id: GE-20260813-keyed-summarisation-runner-api
title: KeyedSummarisationRunner takes completionTest + staleTimeout, not WindowPolicy
category: gotcha
domain: casehub-blocks
tags: [summarisation, api-mismatch]
created: 2026-08-13
freshness: 2026-08-13
---

`KeyedSummarisationRunner<K, IN, OUT>` constructor takes `(Function<IN, K> keyExtractor, Predicate<List<LevelEvent<IN>>> completionTest, long staleTimeout, ...)` — NOT a `WindowPolicy`. Only `SummarisationRunner<IN, OUT>` accepts `WindowPolicy`. The fsitrading C2 spec initially used `WindowPolicy.ofAge(60_000)` for the keyed runner (Level 1), which doesn't compile. The correct approach: encode the 60-second window logic in the `completionTest` predicate (`batch age >= 60s`) and set `staleTimeout` to 90s for sparse overnight ticks.
