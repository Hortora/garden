---
id: PP-20260610-7a3d08
title: "Tenant isolation tests require both wrong-tenant (404) and bypass (200) assertions"
type: rule
scope: application
applies_to: "casehub-clinical — all *ResourceTest and service test classes that add findByIdForTenant call sites"
severity: important
refs:
  - docs/specs/2026-06-09-tenant-query-isolation-design.md
violation_hint: "A test class adds a findByIdForTenant call site but has only an isolation test (wrong-tenant → 404) with no corresponding bypass test (setCrossTenantAdmin(true) → 200)"
garden_ref: GE-20260610-952c8d
created: 2026-06-10
---

Every new `findByIdForTenant` call site in a REST resource or service must be covered by two tests in the corresponding test class: (1) an isolation test — switch `FixedCurrentPrincipal.setTenancyId("other-tenant")`, assert the endpoint returns 404; and (2) a bypass test — switch to `"other-tenant"` and call `setCrossTenantAdmin(true)`, assert the endpoint returns 200. The isolation test verifies the security guard; the bypass test verifies `isCrossTenantAdmin()` is correctly wired through `findByIdForTenant` at the service layer. Without the bypass test, a CDI wiring regression (e.g. `CurrentPrincipal` not injected into a service) would cause the bypass to silently return 404 for admins with no test failure. All test classes that inject `FixedCurrentPrincipal` must also have `@AfterEach void resetPrincipal() { principal.reset(); }` to prevent state bleed between tests.
