---
id: PP-20260602-2fa080
title: "Run three-check quality sweep before closing ARC42STORIES.MD migration issue"
type: rule
scope: application
applies_to: "CaseHub harness apps migrating LAYER-LOG.md to ARC42STORIES.MD"
severity: important
refs:
  - ../../jvm/GE-20260601-b0eabf.md
  - ../../jvm/GE-20260601-c09f71.md
  - ../../jvm/GE-20260601-85afd0.md
violation_hint: "Issue closed with §12 listing closed issues as active risks, or Key files naming non-existent classes, or CDI annotations that don't match production code"
created: 2026-06-02
---

After generating ARC42STORIES.MD from LAYER-LOG.md, three checks are mandatory before closing the migration issue. (1) Run `gh issue view N --repo casehubio/REPO` for every issue reference in §12 — closed issues must be removed from Active Risks; (2) Run `find . -name "ClassName.java"` for every class in §9.4 Key files sections — class names from design docs may not exist in production; (3) Open each service implementation and verify CDI annotations match the document — `@ApplicationScoped` may have evolved to `@Alternative @Priority(N)` when competing implementations were introduced. The devtown migration found 10+ documentation errors using these three checks. See garden entries GE-20260601-b0eabf, GE-20260601-c09f71, GE-20260601-85afd0 for the specific gotchas each check catches.
