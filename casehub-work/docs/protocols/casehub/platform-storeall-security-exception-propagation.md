---
id: PP-20260620-d9675c
title: "storeAll() must propagate SecurityException immediately — never collect it"
type: rule
scope: platform
applies_to: "Any CaseMemoryStore.storeAll() override or the default implementation — all adapters: inmem, jpa, sqlite, mem0, graphiti, noop"
severity: critical
refs:
  - platform-api/src/main/java/io/casehub/platform/api/memory/CaseMemoryStore.java
  - platform-api/src/main/java/io/casehub/platform/api/memory/StoreAllResult.java
violation_hint: "A storeAll() implementation catches SecurityException and places it in StoreAllResult.failures() instead of re-throwing — allows cross-tenant writes to silently appear successful to the caller"
created: 2026-06-20
---

`CaseMemoryStore.storeAll()` overrides MUST re-throw `SecurityException` immediately when any `MemoryPermissions.assertTenant()` call fires. `SecurityException` is an authorization failure — it must never be swallowed or collected in `StoreAllResult.failures()`. Only backend `RuntimeException`s (network errors, DB failures, serialization exceptions) belong in `failures`. The distinction is enforced in the default implementation and in the CaseMemoryStoreSpiTest contract test. Adapters that do pre-flight tenant checks (assertTenant on all inputs before any backend call) must still throw when a check fails, even if prior inputs were already stored — the transactional contract (via JDBC or pre-flight) governs rollback, but the SecurityException itself always propagates to the caller.
