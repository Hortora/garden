---
id: PP-20260529-e30ebd
title: "Life-domain Qhorus channels use the life/ namespace prefix and domain-scoped names"
type: rule
scope: application
applies_to: "casehub-life — any code creating or referencing Qhorus channels in the life application layer"
severity: guidance
refs:
  - casehub-life/LAYER-LOG.md
  - casehub-life/docs/specs/life-actor-model.md
violation_hint: "A life-layer channel named /work, /observe, or /oversight (without life/ prefix) — or a channel named after the normative mesh layout — is misplaced"
created: 2026-05-29
---

Life-domain Qhorus channels are household coordination channels, distinct from the normative 3-channel agent orchestration mesh (`/work`, `/observe`, `/oversight` suffix convention) governed by Claudony's `NormativeChannelLayout` SPI. All life-domain channels use the `life/` namespace prefix with domain-scoped names: `life/delegation` (shared, family task delegation), `life/oversight` (shared, major decision gates — allowedTypes restricted to COMMAND+RESPONSE), and `life/actor/{externalActorId}` (per-actor, contractor commitments). Future life channels must follow this pattern — prefix `life/`, then a domain-meaningful segment — not the normative suffix convention. One APPROVAL_PENDING Watchdog is registered per channel at channel creation.
