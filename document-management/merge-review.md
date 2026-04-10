---
title: "8-point review checklist for merging multiple documents into one"
type: technique
domain: document-management
score: 12
tags: [documentation, merging, review, consolidation, quality]
verified: true
staleness_threshold: P5Y
summary: "Systematic 8-check process for document consolidation that catches defects ad-hoc editing misses — each check targets a distinct defect class."
---

**ID:** GE-0004
**Stack:** Any — documentation methodology, Markdown, technical writing

## What developers normally do instead

Merge content by section, do a quick readthrough, declare done. This reliably leaves stale terms from earlier versions, missing content from older sources that the newest doesn't repeat, internal inconsistencies between sections written at different times, and broken cross-references.

## The technique

Run 8 explicit checks after every merge, in order:

**1. Decision coverage** — Every decision in every source document's decision tables must appear in the merged result. Cross-tick row by row. Any missing row is a gap.

**2. Conflict scan** — Grep for stale terms: old version numbers, removed class names, deprecated API calls, old plan language, bugs listed as open that were fixed in a later source. Each hit must be removed or marked as superseded.

**3. Stale reference scan** — Renamed or removed concepts appearing without a "superseded" note. If something was renamed in source N, it must not appear uncorrected in the merged doc.

**4. Gap check** — Every item in the most recent source's "Next Steps" and "Open Questions" must appear somewhere in the merged doc — in Next Steps, Open Questions, or explicitly marked as deferred. Go line by line.

**5. Redundancy/overlap** — Read every section. Flag any concept described in two different sections. Either consolidate or make one definitive and have the other reference it.

**6. Non-Goals audit** — If the merged doc has a Non-Goals section, check every item: is any now in scope per the most recent source? If no Non-Goals section, check for items called "deferred" in early sources that are still unaddressed.

**7. Cross-reference integrity** — Every "see §X" or internal link must point to a real section with the right content. Read each one.

**8. Readability pass** — Read the full merged doc as a new reader. Does each section lead naturally to the next? Dangling references? Terminology consistent? Decision tables in the right sections?

```
Checks 1–3: correctness (no wrong content)
Checks 4–6: completeness (no missing content)
Checks 7–8: coherence (no structural defects)
```

## Why this is non-obvious

The natural instinct after merging is a single readthrough. But each structured check catches a different defect class that the others miss:
- **Grep-based checks** catch stale terms that read fine but refer to removed concepts
- **Line-by-line gap checks** catch items the newest source assumed as read
- **Non-Goals audits** catch scope changes not explicitly flagged as reversals
- **Readability pass** is the only check that catches cross-section terminology drift

Running 3 of 8 produces a document that feels finished but has real errors in the unchecked categories.

## Evidence from application

Applied to 4 projects (CaseHub, QuarkMind, cccli, remotecc) in a single session. Every application caught real defects:
- CaseHub: Non-Goals audit found sub-cases and retry/timeout now in-scope
- QuarkMind: Gap check found 3 missing Next Steps items; readability found "Phase 1/2" meaning Drools rule phases (not project phases)
- cccli: Gap check found deferred NSTextField→NSTextView missing; readability found ambiguous AnsiStripper dev-fallback path in Data Flow
- remotecc: Gap check found `--mcp-config` decision missing from decisions table; readability found `resizePane` contradicting Architecture section (which documented the fix to `resizeWindow`)
