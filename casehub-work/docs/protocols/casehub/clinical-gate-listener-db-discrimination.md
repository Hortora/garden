---
id: PP-20260614-09e213
title: "Gate @ConsumeEvent listeners discriminate by DB query — never by CaseInstanceCache.getPendingActionGate()"
type: rule
scope: application
applies_to: "casehub-clinical — all *GateDecisionListener beans subscribing to casehub.action.gate.* addresses"
severity: critical
refs:
  - docs/specs/2026-06-12-susar-fix-gdpr-design.md
violation_hint: "Listener calls CaseInstanceCache.get(event.caseId()).getPendingActionGate() to determine gate type — returns null non-deterministically when engine handler runs first"
garden_ref: "GE-20260613-29d3b5"
created: 2026-06-14
---

When a clinical `@ConsumeEvent(blocking = true)` handler subscribes to `casehub.action.gate.rejected`, `casehub.action.gate.approved`, or `casehub.action.gate.expired`, gate type discrimination must use a domain DB query — never `CaseInstanceCache.getPendingActionGate()`. The engine's gate handlers (`ActionGateRejectedHandler`, `ActionGateExpiredHandler`) are competing `@ConsumeEvent` consumers on the same addresses and clear `pendingActionGate` synchronously before publishing downstream; by the time the clinical consumer runs, the cache returns null and the ledger write is silently skipped — an FDA audit gap. The correct pattern: store `susarOversightCaseId` (or the relevant case ID) on the domain entity during Phase 3 of the three-phase start sequence, then query `DomainEntity.findByCaseId(event.caseId())` in the listener. Non-null signals "this gate belongs to me." See `SusarGateDecisionListener` for the reference implementation.
