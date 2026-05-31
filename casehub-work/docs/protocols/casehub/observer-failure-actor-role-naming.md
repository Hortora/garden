---
id: PP-20260531-11724b
title: "Observer failure ledger entries use actorRole = <successRole>-observer-failed and ClinicalActors.CLINICAL_SERVICE as actorId"
type: rule
scope: application
applies_to: "io.casehub.clinical.service.*LedgerWriter — all writeObserverFailureEntry methods"
severity: guidance
refs:
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/AeEscalationLedgerWriter.java
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/IrbApprovalLedgerWriter.java
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/SafetyOfficerNotificationLedgerWriter.java
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/DeviationLedgerWriter.java
violation_hint: "A writeObserverFailureEntry method uses an ad-hoc actorRole string not derived from the corresponding success entry's role, or uses 'irb-committee' / another human-actor id instead of ClinicalActors.CLINICAL_SERVICE"
created: 2026-05-31
---

Observer failure ledger entries (written by `writeObserverFailureEntry` methods) must use `actorRole = <successRole> + "-observer-failed"`, where `<successRole>` is the actorRole used by the corresponding success-path writer method (e.g. `"AeEscalationCase"` → `"AeEscalationCase-observer-failed"`; `"IrbCommittee"` → `"IrbCommittee-observer-failed"`; `"sponsor-notifier"` → `"sponsor-notifier-observer-failed"`). This naming makes failure entries discoverable by actorRole suffix in FDA audit queries and unambiguously identifies them as observer-level failures rather than successful domain events. All observer failure entries must also use `actorId = ClinicalActors.CLINICAL_SERVICE` and `actorType = ActorType.SYSTEM` — the entry records a system-level failure, not a decision made by the human or external actor recorded in the success entry.
