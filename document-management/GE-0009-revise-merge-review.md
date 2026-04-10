---
title: "REVISE GE-0004: add scan-for-old-name tip to readability pass"
type: technique
domain: document-management
score: 8
tags: [documentation, merging, review, consolidation, readability, api-naming]
verified: true
staleness_threshold: P3Y
summary: "Enriches GE-0004's readability pass description with a specific actionable tip: when a section documents a fix ('use X, not Y'), scan the whole document for Y."
---

**Submission ID:** GE-0009
**Revision kind:** update
**Target entry:** GE-0004 — "8-point review checklist for merging multiple documents into one"
**Target file:** `document-management/merge-review.md`

## What to add

In the section describing **Check 8 (Readability pass)**, add the following tip after the existing description:

> **Specific pattern to watch for:** When one section documents an API rename or bug fix ("use `resize-window`, not `resize-pane`" or "use X not Y"), actively search the rest of the document for the old name Y. Conflict-scan (Check 2) misses this because Y is still a valid identifier — only the context of the correction in another section makes it stale.

## Why it enriches rather than stands alone

This tip is a specific sub-technique of the readability pass that was discovered concretely in remotecc's merge (already cited as an example in GE-0004's Evidence section). It doesn't justify its own entry at 5/15 but adds genuine precision to GE-0004's guidance on what to look for during the readability pass — turning a general "read coherently" instruction into a specific searchable pattern.

## Evidence

In remotecc's DESIGN.md after consolidation:
- Architecture section: "`tmux resize-window` (not `resize-pane` — works for detached sessions)"
- Data Flow section: `TmuxService.resizePane(cols, rows)`

The Architecture section explicitly documented the fix; the Data Flow section carried the old method name from before the fix. Neither conflict-scan nor any other structured check caught it — only the readability pass did, because a reader encountering both sections in sequence notices the contradiction.
