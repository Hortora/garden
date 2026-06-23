---
id: PP-20260623-b105bb
title: "ClinicalActionRiskClassifier must not use RBAC-differentiated thresholds"
type: rule
scope: application
applies_to: "casehub-clinical — ClinicalActionRiskClassifier and any future ActionRiskClassifier"
severity: important
refs:
  - specs/2026-06-23-oidc-platform-wiring-design.md
violation_hint: "Role-based threshold overrides in ClinicalActionRiskClassifier (e.g. admin elevated spend threshold)"
created: 2026-06-23
---

Clinical risk gates in `ClinicalActionRiskClassifier` are driven by CTCAE grade, unexpected/suspected flags, and 21 CFR 312.32 reporting requirements — objective clinical severity signals independent of who triggered them. No role-based threshold overrides. The life harness (`LifeActionRiskClassifier`) uses RBAC-differentiated thresholds (admin elevated, junior always-gate) because financial thresholds are negotiable by authority. Clinical gates are not — a sponsor cannot negotiate away a Grade 4 AE's 24-hour SLA. This is a stronger compliance story.
