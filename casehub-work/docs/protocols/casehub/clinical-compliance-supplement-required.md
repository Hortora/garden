---
id: PP-20260614-377e99
title: "All clinical AI agent decision ledger entries must attach ClinicalComplianceSupplement before save"
type: rule
scope: application
applies_to: "casehub-clinical — all *LedgerWriter beans writing primary AI decision entries (LedgerEntryType.EVENT or ATTESTATION for a consequential agent action)"
severity: important
refs:
  - docs/specs/2026-06-12-susar-fix-gdpr-design.md
violation_hint: "LedgerWriter calls ledgerEntryRepository.save() without preceding entry.attach(ClinicalComplianceSupplement.xxx()) — missing EU AI Act Art.12 planRef and algorithmRef"
created: 2026-06-14
---

Every clinical ledger writer that records a consequential AI agent decision (adverse event escalation, IRB gate decision, protocol deviation, SUSAR gate, safety officer notification, sponsor notification) must call `entry.attach(ClinicalComplianceSupplement.<type>())` immediately before `ledgerEntryRepository.save()`. `ClinicalComplianceSupplement` in `runtime/.../service/` is the canonical source of `planRef` (GCP/FDA reference string) and `algorithmRef` (which algorithm or policy produced the decision) — do not inline these strings in individual writers. The `attach()` method (on `LedgerEntry`) associates a `ComplianceSupplement` via the `@OneToMany supplements` relationship; use the runtime type `io.casehub.ledger.runtime.model.supplement.ComplianceSupplement` (not the API POJO). Failure to attach means the PROV-DM export lacks regulatory context, and EU AI Act Art.12 transparency requirements are unmet.
