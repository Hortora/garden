---
id: PP-20260609-ea07e4
title: "Separate GRADE and OUTCOME in clinical AE memory entries"
type: rule
scope: application
applies_to: "casehub-clinical ClinicalMemoryService — all AE memory writes to PATIENT domain"
severity: critical
refs:
  - runtime/src/main/java/io/casehub/clinical/memory/ClinicalMemoryAttributes.java
  - runtime/src/main/java/io/casehub/clinical/memory/ClinicalMemoryService.java
violation_hint: "A storeAeReport or storeAeOutcome call stores grade.name() as MemoryAttributeKeys.OUTCOME, or toContextMap() produces facts without a 'grade' key"
created: 2026-06-09
---

AE memory entries written to the PATIENT domain must carry `ClinicalMemoryAttributes.GRADE` (CTCAE grade name, e.g. "GRADE_3") and `MemoryAttributeKeys.OUTCOME` (lifecycle status: "REPORTED", "ESCALATED", "DSMB_ESCALATED") as **separate attributes**. Conflating them — storing `grade.name()` as `OUTCOME` — breaks `hasPriorGrade3OrAbove()` for escalation entries and produces a facts map without a `grade` key, violating the spec contract at `.patientContext.facts[].grade`. The `ClinicalMemoryAttributes.GRADE` key is the canonical way to carry CTCAE grade through the memory store; `OUTCOME` is always a lifecycle or resolution status, never a grade.
