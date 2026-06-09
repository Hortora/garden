# CaseHub Application Harness Protocols

Standing rules for applications built on the CaseHub platform (casehub-life, casehub-aml, casehub-clinical, casehub-devtown, etc.).

| File | Rule Summary | Applies To |
|------|-------------|------------|
| [life-domain-channel-naming.md](life-domain-channel-naming.md) | Life-domain Qhorus channels use the `life/` namespace prefix and domain-scoped names — not the normative mesh layout | casehub-life — any code creating or referencing Qhorus channels in the life layer |
| [clinical-actor-id-constant.md](clinical-actor-id-constant.md) | All clinical system-actor ledger writes must use `ClinicalActors.CLINICAL_SERVICE` — never a string literal | casehub-clinical — all `*LedgerWriter` beans recording system-initiated actions |
| [observer-ledger-fallback.md](observer-ledger-fallback.md) | `@ObservesAsync @Transactional` observers with GCP ledger obligations require double try/catch + REQUIRES_NEW fallback writer + ledgerWritten guard | casehub-clinical — all `*Listener` beans writing GCP-required ledger entries |
| [observer-failure-actor-role-naming.md](observer-failure-actor-role-naming.md) | Observer failure entries use actorRole = `<successRole>-observer-failed` and `ClinicalActors.CLINICAL_SERVICE` as actorId | casehub-clinical — all `*LedgerWriter` beans with `writeObserverFailureEntry` methods |
| [notification-listener-skip-path-audit.md](notification-listener-skip-path-audit.md) | Notification listeners must write a `delivered=false` ledger entry with skip-reason-encoded `actorRole` for every deliberate skip path | casehub-clinical — all `*NotificationListener` beans with deliberate early-return paths |
| [devtown-preferences-package-placement.md](devtown-preferences-package-placement.md) | General-purpose `SingleValuePreference` types go in `domain.preferences`, not domain-specific sub-packages | casehub-devtown — any new `SingleValuePreference` subtype |
| [platform-config-one-yaml-per-concern.md](platform-config-one-yaml-per-concern.md) | One YAML file per logical concern in `casehub.platform.config.files` — no mixing scope prefixes | casehub-devtown (and any domain app using casehub-platform-config) |
| [clinical-memory-domain-entity-id-convention.md](clinical-memory-domain-entity-id-convention.md) | CaseMemoryStore entityIds use `{entity-type}:{uuid}` prefix — PATIENT=`patient:{enrollmentId}`, SITE=`site:{siteId}`, DRUG=`trial:{trialId}`, IRB=`deviation-type:{deviationType}` | casehub-clinical — all ClinicalMemoryService reads and writes |
| [clinical-ae-memory-grade-outcome-separation.md](clinical-ae-memory-grade-outcome-separation.md) | AE memory entries carry GRADE and OUTCOME as separate attributes — never store grade.name() as OUTCOME | casehub-clinical — all `storeAeReport`/`storeAeOutcome` calls |

| [arc42stories-post-generation-quality-gate.md](arc42stories-post-generation-quality-gate.md) | Run three checks after generating ARC42STORIES.MD: gh issue view for §12 refs, find for Key files classes, verify CDI annotations | Any CaseHub harness app migrating LAYER-LOG.md to ARC42STORIES.MD |
| [arc42stories-primary-record-declaration.md](arc42stories-primary-record-declaration.md) | At ARC42STORIES.MD bootstrap: update CLAUDE.md to declare ARC42STORIES.MD as primary record, LAYER-LOG.md as source-of-truth draft; add DESIGN.md redirects; do not retire LAYER-LOG.md until verified complete | Any CaseHub harness app bootstrapping ARC42STORIES.MD |
| [arc42stories-project-repo-placement.md](arc42stories-project-repo-placement.md) | ARC42STORIES.MD belongs in the project repo root, not the workspace — equivalent placement to DESIGN.md before migration | Any CaseHub harness application using ARC42STORIES.MD as its architecture record |
