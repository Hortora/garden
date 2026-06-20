---
id: PP-20260620-e9355b
title: "Annotate all 7 CaseMemoryStore public methods with @Timed"
type: rule
scope: platform
applies_to: "Any class implementing CaseMemoryStore or GraphCaseMemoryStore — all seven public methods: store, storeAll, query, erase, eraseById, eraseEntity, eraseEntityAcrossTenants"
severity: important
refs:
  - memory-mem0/src/main/java/io/casehub/platform/memory/mem0/Mem0CaseMemoryStore.java
  - memory-graphiti/src/main/java/io/casehub/platform/memory/graphiti/GraphitiCaseMemoryStore.java
violation_hint: "A CaseMemoryStore adapter class is missing @Timed on one or more of the 7 public methods, leaving operations invisible to Micrometer metrics"
created: 2026-06-20
---

Every `CaseMemoryStore` adapter that overrides any of the 7 public interface methods must annotate each override with `@Timed(value = "casehub.memory.<adapter>", histogram = true, extraTags = {"operation", "<op-name>"})` where `<adapter>` is the short adapter name (e.g. `jpa`, `sqlite`, `mem0`, `graphiti`) and `<op-name>` matches the method name (e.g. `store`, `storeAll`, `query`, `erase`, `eraseById`, `eraseEntity`, `eraseEntityAcrossTenants`). Adapters that do not override a method inherit the default implementation and need no annotation. Add `micrometer-core` as a compile-scope dependency to the adapter's pom.xml if not already present — the parent BOM manages the version.
