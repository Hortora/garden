---
id: PP-20260610-8c6b88
title: "Child entity tenantId derives from parent entity, not from principal.tenancyId()"
type: rule
scope: application
applies_to: "casehub-clinical — all REST resource write paths that create child entities (SiteResource.add, PatientResource.enroll, DeviationResource.reportDeviation, AdverseEventService.reportAdverseEvent)"
severity: important
refs:
  - docs/specs/2026-06-09-tenant-query-isolation-design.md
violation_hint: "entity.tenantId = principal.tenancyId() on a child entity create path when a parent entity has already been loaded"
created: 2026-06-10
---

When creating a child entity in casehub-clinical, stamp `child.tenantId` from the already-loaded parent entity's `tenantId`, not from `principal.tenancyId()`. The invariant is `child.tenantId == parent.tenantId`. Using `principal.tenancyId()` causes a cross-tenant admin to stamp child entities with the admin's own tenant rather than the target tenant, making those entities invisible to the target tenant on subsequent reads (they are reachable by no one). Concretely: `site.tenantId = trial.tenantId`, `enrollment.tenantId = site.tenantId`, `deviation.tenantId = site.tenantId`, `ae.tenantId = enrollment.tenantId` (derived internally in the service). `ClinicalTrial` is a root entity with no parent — it stamps from `principal.tenancyId()`, which is correct and unchanged.
