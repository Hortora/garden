---
title: "Mark document sections CURRENT/STALE/MISSING before surgical merge editing"
type: technique
domain: document-management
score: 8
tags: [documentation, merging, editing, consolidation, surgical-editing]
verified: true
staleness_threshold: P3Y
summary: "Before editing a document to merge in new content, classify each section as CURRENT, STALE, or MISSING. This prevents both over-editing (rewriting accurate content) and under-editing (leaving stale content)."
---

**ID:** GE-0008
**Stack:** Any — documentation methodology, Markdown, technical writing

## Context

When merging multiple versioned source documents (design snapshots, changelogs, session notes) into an existing primary document, you need to know which parts to touch and which to leave alone.

## What developers normally do instead

Read both source and target, then edit the target while holding both in mind. This leads to:
- **Over-editing:** rewriting sections that were already accurate, introducing risk of errors
- **Under-editing:** leaving stale sections because they "looked fine" when briefly scanned
- **Missing content:** not noticing that a concept in the source has no equivalent section in the target

## The technique

Before touching the target document, classify every section:

| Classification | Meaning | Action |
|---|---|---|
| **CURRENT** | Accurate relative to the newest source | Leave untouched |
| **STALE** | Exists but describes something now superseded | Update or remove |
| **MISSING** | In the source but absent from the target | Add new section/content |

**Step 1:** Read all source documents (newest first). Build a mental model of "what is currently true."

**Step 2:** Scan the target document's section list (headings only, not full content):
```bash
grep "^## \|^### " docs/DESIGN.md
```

**Step 3:** For each section in the target, classify against your mental model. For each concept in the source, check whether a section exists in the target.

**Step 4:** Edit only STALE and MISSING sections. CURRENT sections are not touched.

## Why this is non-obvious

The temptation when merging is to work top-to-bottom through the target document and "update as you go." Classification-first breaks that instinct and creates a clear separation between *analysis* (what needs changing) and *execution* (making the changes). The discipline of explicitly marking sections also makes the scope of work visible — you know how much you have to do before you start, which prevents both premature stopping and endless scope creep.

For primary documents that were "roughly right" before the merge (e.g. a DESIGN.md that was updated 2 days ago), classification-first often reveals that 70–80% of sections are CURRENT and can be skipped entirely — saving significant effort while ensuring nothing stale slips through.
