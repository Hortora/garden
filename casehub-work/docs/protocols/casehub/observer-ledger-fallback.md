---
id: PP-20260530-49856c
title: "@ObservesAsync @Transactional observers with GCP ledger obligations require REQUIRES_NEW fallback and double try/catch"
type: rule
scope: application
applies_to: "io.casehub.clinical.service.*Listener — any @ObservesAsync observer that writes a GCP-required ledger entry"
severity: important
refs:
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/SafetyOfficerNotificationListener.java
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/SponsorNotificationListener.java
violation_hint: "An observer has a single try/catch with no fallback ledger write, or has a fallback write without an inner catch around it"
created: 2026-05-30
---

`@ObservesAsync @Transactional` observers that satisfy GCP/FDA audit obligations (ICH E6(R3) §5.17, 21 CFR 312.32) must implement a double try/catch: an outer catch handles unexpected exceptions from the main logic and calls a `writeObserverFailureEntry(@Transactional REQUIRES_NEW)` method on the relevant ledger writer; an inner catch around that fallback call logs `"AUDIT GAP: ..."` if even the fallback write fails. The REQUIRES_NEW isolation ensures the fallback entry commits even when the outer observer transaction is in rollback-only state. Without this pattern, an unexpected exception is silently swallowed by the `@ObservesAsync` dispatcher — the ledger entry is never written and the absence is indistinguishable from "the notification was never triggered", which is a GCP compliance gap.
