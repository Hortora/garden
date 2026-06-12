| GE-ID | Title | Type | Score |
|-------|-------|------|-------|
| GE-20260511-b6f903 | casehub-ledger LedgerEntry subclass: 7 required fields for LedgerEntryRepository.save() — none documented | undocumented | 12/15 |
| GE-20260511-b6f903 | casehub-ledger LedgerEntry subclass: required caller-set fields for LedgerEntryRepository.save() — none documented | undocumented | 12/15 |
| GE-20260531-d2ed26 | LedgerEntryRepository.save() triggers full Merkle chain update — concurrent writes violate UQ_MERKLE_FRONTIER_SUBJECT_LEVEL | gotcha | 8/15 |
| GE-20260531-1587fe | JpaLedgerMerkleFrontierRepository must be added to selected-alternatives alongside JpaLedgerEntryRepository for LedgerVerificationService to work in @QuarkusTest | undocumented | 8/15 |
| GE-20260531-46f8ab | casehub.ledger.identity.tokenisation.enabled=true required in tests for LedgerErasureService.erase() to do anything | undocumented | 8/15 |
| GE-20260612-de141c | casehub-ledger LedgerProcessor build step requires domainContentBytes() on all LedgerEntry subclasses with @Column fields | gotcha | 10/15 |
| GE-20260612-17c161 | casehub-ledger LedgerProcessor build step blocks em.persist() on LedgerEntry subclasses — use LedgerEntryRepository.save() | gotcha | 12/15 |
