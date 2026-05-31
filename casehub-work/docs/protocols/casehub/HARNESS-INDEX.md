# CaseHub Application Harness Protocols

Standing rules for applications built on the CaseHub platform (casehub-life, casehub-aml, casehub-clinical, casehub-devtown, etc.).

| File | Rule Summary | Applies To |
|------|-------------|------------|
| [life-domain-channel-naming.md](life-domain-channel-naming.md) | Life-domain Qhorus channels use the `life/` namespace prefix and domain-scoped names — not the normative mesh layout | casehub-life — any code creating or referencing Qhorus channels in the life layer |
| [clinical-actor-id-constant.md](clinical-actor-id-constant.md) | All clinical system-actor ledger writes must use `ClinicalActors.CLINICAL_SERVICE` — never a string literal | casehub-clinical — all `*LedgerWriter` beans recording system-initiated actions |
| [observer-ledger-fallback.md](observer-ledger-fallback.md) | `@ObservesAsync @Transactional` observers with GCP ledger obligations require double try/catch + REQUIRES_NEW fallback writer + ledgerWritten guard | casehub-clinical — all `*Listener` beans writing GCP-required ledger entries |
| [observer-failure-actor-role-naming.md](observer-failure-actor-role-naming.md) | Observer failure entries use actorRole = `<successRole>-observer-failed` and `ClinicalActors.CLINICAL_SERVICE` as actorId | casehub-clinical — all `*LedgerWriter` beans with `writeObserverFailureEntry` methods |
