---
id: PP-20260609-5518d7
title: "Use typed-prefix entityId for all clinical CaseMemoryStore domains"
type: rule
scope: application
applies_to: "casehub-clinical ClinicalMemoryService — all CaseMemoryStore reads and writes"
severity: important
refs:
  - runtime/src/main/java/io/casehub/clinical/memory/ClinicalMemoryDomains.java
  - runtime/src/main/java/io/casehub/clinical/memory/ClinicalMemoryService.java
violation_hint: "A domain write or query uses a raw UUID string without a typed prefix, or uses the wrong entity type for a domain (e.g. siteId for the DRUG domain instead of trialId)"
created: 2026-06-09
---

Every CaseMemoryStore entityId in casehub-clinical follows a `{entity-type}:{uuid}` prefix convention — the prefix makes the entity type explicit and prevents accidental cross-domain collisions. The four domains and their canonical entityId formats are: PATIENT → `patient:{enrollmentId}`; SITE → `site:{siteId}`; DRUG → `trial:{trialId}` (cross-site AE signals per protocol; trialId resolved via TrialSite.findById(siteId)); IRB → `deviation-type:{deviationType}` (decision precedent per type; skip write when deviationType is null). Adding a new domain requires choosing an entityId prefix that matches the aggregate scope of what is stored — not the triggering event.
