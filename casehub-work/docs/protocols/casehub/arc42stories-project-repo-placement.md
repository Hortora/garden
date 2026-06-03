---
id: PP-20260603-33c84c
title: "ARC42STORIES.MD lives in the project repo, not the workspace"
type: rule
scope: application
applies_to: "Any CaseHub harness application using ARC42STORIES.MD as its architecture record"
severity: important
refs:
  - casehub/HARNESS-INDEX.md
violation_hint: "ARC42STORIES.MD found in the workspace root (mdproctor/wsp-casehub-*) instead of the project repo root"
created: 2026-06-03
---

ARC42STORIES.MD is the architecture record for a CaseHub application — equivalent to DESIGN.md before the migration. Like DESIGN.md, it belongs in the project repo root (e.g. `casehubio/devtown`), not the workspace. The workspace holds methodology artifacts (handovers, blog, plans, snapshots); architectural documentation belongs alongside the code where contributors can read it. When the migration from DESIGN.md to ARC42STORIES.MD happened, several repos accidentally placed the file in the workspace — audit with: find the file under `~/claude/casehub/<repo>/` (project) vs `~/claude/public/casehub/<repo>/` (workspace).
