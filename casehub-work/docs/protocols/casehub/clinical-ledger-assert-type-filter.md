---
id: PP-20260619-5dfddd
title: "Ledger count assertions in @QuarkusTest must filter by LedgerEntry subclass"
type: rule
scope: application
applies_to: "Any @QuarkusTest that asserts on ledger entry counts via LedgerEntryRepository.findBySubjectId()"
severity: guidance
refs:
  - casehub-clinical/runtime/src/test/java/io/casehub/clinical/service/ProtocolAmendmentIntegrationTest.java
  - casehub-clinical/runtime/src/test/java/io/casehub/clinical/resource/ThreeSiteShowcaseTest.java
violation_hint: "ledgerRepo.findBySubjectId(id, tenancyId).size() == 2 without instanceof filter — fails intermittently when background observers write additional entries for the same subjectId"
created: 2026-06-19
---

Ledger entry count assertions that rely on `findBySubjectId().size()` without filtering by subclass will fail intermittently. Multiple services can write entries to the same subject chain (e.g. safety officer notification, escalation, resolution observers), and the exact count depends on which async observers have fired by assertion time. Use `instanceof` to filter: `findBySubjectId(id, tenancyId).stream().filter(e -> e instanceof SpecificLedgerEntry).count()`. This makes the assertion correct by construction regardless of which other entries are present.
