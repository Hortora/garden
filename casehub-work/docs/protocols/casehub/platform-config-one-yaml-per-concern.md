---
id: PP-20260531-ea9945
title: "One casehub-platform-config YAML file per logical concern"
type: rule
scope: application
applies_to: "any casehub-devtown (or domain app) YAML file loaded via casehub.platform.config.files"
severity: guidance
refs:
  - devtown#58
violation_hint: "A single YAML file mixes trust routing and trust gate entries under different scope prefixes (e.g. casehubio/devtown/trust-routing and casehubio/devtown/trust-gate in the same file)"
created: 2026-05-31
---

Each YAML file loaded via `casehub.platform.config.files` must serve one logical concern and use a single consistent scope namespace prefix. Mixing unrelated concerns in one file (e.g. routing policy + gate config) makes individual concerns harder to replace, extend, or reason about. Trust routing lives in `trust-routing.yaml` (scope prefix `casehubio/devtown/trust-routing`); trust gate lives in `trust-gate.yaml` (scope prefix `casehubio/devtown/trust-gate`). Add a new file for each new concern rather than appending to an existing one.
