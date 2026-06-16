---
id: PP-20260617-3167e3
title: "Extending IND reporting to a new CTCAE grade requires updating three locations atomically"
type: rule
scope: application
applies_to: "casehub-clinical — RegulatorySubmissionCaseService, ClinicalComplianceSupplement, any future regulatory submission path"
severity: important
refs:
  - docs/specs/2026-06-16-grade3-ind-expedited-design.md
violation_hint: "A grade is added to isIndReportable() but not to indReportingWindow() or regulatorySubmission() — causes IllegalArgumentException at runtime on the first matching event. Or a grade is handled by indReportingWindow() but not isIndReportable() — dead code, the grade is never triggered."
created: 2026-06-16
---

When a new CTCAE grade must trigger IND expedited safety reporting, three locations in `casehub-clinical` must be updated together: (1) `RegulatorySubmissionCaseService.isIndReportable(CtcaeGrade)` — add the grade to the reportable predicate; (2) `RegulatorySubmissionCaseService.indReportingWindow(CtcaeGrade)` — add its reporting window (e.g. `GRADE_4 -> Duration.ofDays(7)`); (3) `ClinicalComplianceSupplement.regulatorySubmission(CtcaeGrade)` — add the grade's CFR citation planRef to the switch expression. A partial update (any two without the third) either silently skips reporting or throws `IllegalArgumentException` at the first matching adverse event. The pending Grade 4 extension (casehubio/clinical#82) must follow this pattern.
