---
id: PP-20260623-491bb3
title: "Clinical REST endpoints must follow GCP-derived RBAC topology"
type: rule
scope: application
applies_to: "casehub-clinical — all REST resource classes"
severity: important
refs:
  - specs/2026-06-23-oidc-platform-wiring-design.md
violation_hint: "SPONSOR on a site-level write endpoint, or MONITOR on any write endpoint"
created: 2026-06-23
---

Every REST endpoint in casehub-clinical must assign `@RolesAllowed` roles according to the ICH E6(R3) / 21 CFR Part 312 regulatory topology: SPONSOR owns trial-level management (create, activate, site selection, sponsor config); INVESTIGATOR and COORDINATOR own site-level clinical data entry (enroll, screen, AEs, deviations); INVESTIGATOR alone owns consent withdrawal (GDPR Art.17) and shares protocol amendment authority with SPONSOR; MONITOR (DSMB) has zero write access by regulatory independence mandate (ICH E6(R3) §5.18.3). All GET endpoints include all four roles. `quarkus.security.deny-unannotated-members=true` catches unannotated methods on annotated classes, but new resource classes with zero annotations are not covered — add `@RolesAllowed` to at least one method immediately.
