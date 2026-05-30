---
id: PP-20260530-d6775a
title: "All clinical harness system-actor ledger writes must use ClinicalActors.CLINICAL_SERVICE"
type: rule
scope: application
applies_to: "io.casehub.clinical.service.*LedgerWriter — any writer setting actorId=SYSTEM"
severity: important
refs:
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/api/ClinicalActors.java
violation_hint: "A ledger writer sets entry.actorId to a string literal ('system', 'clinical-service') rather than ClinicalActors.CLINICAL_SERVICE"
created: 2026-05-30
---

The clinical harness identifies itself in the tamper-evident FDA audit trail as the actor `"clinical-service"`. This identity is shared between the ledger layer (as `actorId`) and the qhorus layer (as `ProtocolDeviationService.CLINICAL_SENDER`). All `*LedgerWriter` beans that record a system-initiated action must use `ClinicalActors.CLINICAL_SERVICE` — never a string literal. A query by actorId is the primary mechanism for an FDA auditor to trace all system-generated entries; an inconsistent actorId silently breaks that query for the affected entry types. `IrbApprovalLedgerWriter` is exempt — it records the IRB committee as a named human actor (`"irb-committee"`, `ActorType.HUMAN`), not the system.
