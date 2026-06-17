---
id: PP-20260617-318449
title: "@QuarkusTest entity creation in @BeforeEach must stamp tenantId = principal.tenancyId()"
type: rule
scope: application
applies_to: "casehub-clinical — all @QuarkusTest @BeforeEach methods that create domain entities directly (not via REST)"
severity: important
refs:
  - docs/protocols/casehub/clinical-child-entity-tenant-stamp.md
violation_hint: "Entity created with no tenantId stamp uses column default 'default'. FixedCurrentPrincipal.tenancyId() returns a UUID. InMemoryMemoryStore.query() calls MemoryPermissions.assertTenant() which throws SecurityException on mismatch. Fails intermittently in full test suite depending on which test ran before — passes when run in isolation."
created: 2026-06-17
---

Any `@QuarkusTest` `@BeforeEach` method that persists a domain entity directly (not through a REST endpoint) must set `entity.tenantId = principal.tenancyId()` before calling `entity.persist()`. Entities created without an explicit tenantId stamp get the H2 column default `"default"`, which mismatches `FixedCurrentPrincipal.tenancyId()` (a fixed UUID). When a service path later calls `ClinicalMemoryService.queryPatientContext(enrollmentId, entity.tenantId)`, `InMemoryMemoryStore.query()` detects the mismatch and throws `SecurityException`. `ClinicalMemoryService` catches and logs the exception (WARN: "returning empty"), but depending on JTA transaction context, this can mark the enclosing `@Transactional` boundary as rollback-only, causing the test to fail. The failure is test-order-dependent (manifests only in the full suite) because it requires a preceding test to have seeded the store with the correct UUID tenant. Reference patterns: `AeEscalationLifecycleTest.setup()`, `AeEscalationContextInjectionTest.setup()`, `SusarOversightLifecycleTest.persistAe()`, `DsmbRollupTest.persistTrial()`.
