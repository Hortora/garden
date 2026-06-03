---
id: PP-20260603-f661dd
title: "Notification listeners must write a delivered=false ledger entry with skip-reason-encoded actorRole for every deliberate skip path"
type: rule
scope: application
applies_to: "io.casehub.clinical.service.*NotificationListener — all deliberate early-return paths"
severity: important
refs:
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/SafetyOfficerNotificationListener.java
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/SponsorNotificationListener.java
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/SafetyOfficerNotificationLedgerWriter.java
violation_hint: "A listener returns silently on a data-quality exit (site not found, trial not found, no config) without writing a ledger entry, or writes a generic 'skipped' actorRole that does not encode the specific reason"
created: 2026-06-03
---

Every deliberate early-return path in a casehub-clinical notification listener (site not found, trial not found, incomplete connector config) must write a `delivered=false` ledger entry via a REQUIRES_NEW writer method. The `actorRole` must encode the specific skip reason using a `-skipped-<reason>` suffix (e.g. `"safety-officer-notifier-skipped-site-not-found"`, not `"skipped"` or `"safety-officer-notifier-skipped"`). ICH E6(R3) §5.17 requires that the fact of non-notification — and the reason for it — be independently verifiable in the tamper-evident audit trail; a generic skip role defeats this. Each skip write must be wrapped in its own try-catch to prevent the failure from reaching the outer observer exception handler (which would write a misleading observer-failure entry instead).
