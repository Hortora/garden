---
id: PP-20260602-1a0c25
title: "Declare ARC42STORIES.MD as primary architecture record at bootstrap — LAYER-LOG.md becomes the source-of-truth draft"
type: rule
scope: application
applies_to: "CaseHub harness apps at the point of bootstrapping ARC42STORIES.MD (casehubio/clinical#54 pattern)"
severity: important
refs:
  - ../parent/docs/arc42stories-spec.md
  - ../parent/docs/arc42stories-casehub-profile.md
  - docs/protocols/casehub/arc42stories-post-generation-quality-gate.md
violation_hint: "CLAUDE.md still lists LAYER-LOG.md as the primary architecture record after ARC42STORIES.MD has been bootstrapped; or LAYER-LOG.md is retired before ARC42STORIES.MD has been verified complete."
created: 2026-06-02
---

When a CaseHub harness app bootstraps `ARC42STORIES.MD`, update `CLAUDE.md` in the same commit to declare `ARC42STORIES.MD` as the primary architecture record and `LAYER-LOG.md` as the source-of-truth draft that feeds it. Also add redirect headers to `docs/DESIGN.md` and workspace `DESIGN.md` pointing to `ARC42STORIES.MD` sections. Do not retire or delete `LAYER-LOG.md` until `ARC42STORIES.MD` has been reviewed and verified complete against all source documents (quality gate: `arc42stories-post-generation-quality-gate.md`). The reference implementation is `casehubio/clinical#54` commit `581b439`.
