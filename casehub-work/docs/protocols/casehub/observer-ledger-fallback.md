---
id: PP-20260530-49856c
title: "@ObservesAsync @Transactional observers with GCP ledger obligations require REQUIRES_NEW fallback, double try/catch, and ledgerWritten guard"
type: rule
scope: application
applies_to: "io.casehub.clinical.service.*Listener — any @ObservesAsync observer that writes a GCP-required ledger entry"
severity: important
refs:
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/SafetyOfficerNotificationListener.java
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/SponsorNotificationListener.java
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/AeEscalationListener.java
  - casehub-clinical/runtime/src/main/java/io/casehub/clinical/service/IrbDecisionListener.java
violation_hint: "An observer has a single try/catch with no fallback ledger write; has a fallback write without an inner catch around it; or has a try/catch without a ledgerWritten boolean guard (risks writing both a success entry and a failure entry when only a downstream fireAsync throws)"
created: 2026-05-30
---

`@ObservesAsync @Transactional` observers that satisfy GCP/FDA audit obligations (ICH E6(R3) §5.17, 21 CFR 312.32) must implement three structural requirements. First, a double try/catch: an outer catch handles unexpected exceptions from the main logic and calls `writeObserverFailureEntry(@Transactional REQUIRES_NEW)` on the relevant ledger writer; an inner catch logs `"AUDIT GAP: ..."` if the fallback write also fails. Second, a `boolean ledgerWritten` flag set immediately after the critical ledger write and before any downstream `fireAsync` call; the outer catch only invokes `writeObserverFailureEntry` when `!ledgerWritten` — if `ledgerWritten` is true and `fireAsync` threw, a caught exception means the outer `@Transactional` commits normally, so both the success entry and the REQUIRES_NEW failure entry would commit, double-recording the event (see GE-20260531-ed2f7a). Third, data resolution (entity loads, context lookups) that cannot produce a meaningful failure entry if it throws must remain outside the try block, so the try block covers only operations where a fallback entry is warranted. Without this pattern, an unexpected exception is silently swallowed by the `@ObservesAsync` dispatcher with no audit trail.
