---
id: PP-20260610-9ee320
title: "Use findByIdForTenant for all REST-facing entity lookups"
type: rule
scope: application
applies_to: "casehub-clinical — all *Resource classes and REST-called services that receive user-supplied entity IDs (TrialActivationService)"
severity: critical
refs:
  - docs/specs/2026-06-09-tenant-query-isolation-design.md
violation_hint: "Plain Entity.findById(id) call in a *Resource class or in TrialActivationService.markActive() where the id comes from user input"
garden_ref: GE-20260610-711f61
created: 2026-06-10
---

All REST-facing entity lookups in casehub-clinical must use `Entity.findByIdForTenant(id, principal)` instead of `Entity.findById(id)`. Plain `findById` is reserved for system-actor contexts — schedulers (`DeviationExpirer`), `@ObservesAsync` CDI observers, and internal service enrichment calls whose IDs were already validated upstream. Using plain `findById` in a resource returns entities regardless of tenant, violating the GDPR Art.5(1)(f) integrity-and-confidentiality obligation and allowing cross-tenant data exposure via UUID guessing. The `isCrossTenantAdmin()` bypass is baked into `findByIdForTenant` — do not replicate it at call sites.
