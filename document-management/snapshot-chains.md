---
title: "Reconstructing parallel supersession chains when Superseded-by fields are blank"
type: technique
domain: document-management
score: 9
tags: [documentation, design-snapshots, supersession, consolidation, chain-reconstruction]
verified: true
staleness_threshold: P3Y
summary: "When versioned documents have blank 'Superseded by' fields but ARE superseded by a later parallel chain, cross-check dates and topics to reconstruct the actual chain before merging."
---

**ID:** GE-0007
**Stack:** Any versioned document system where documents reference predecessors (design snapshots, ADRs, changelogs)

## Context

A design snapshot system where each document has `Superseded by: [link]` and `Supersedes: [link]` fields. When consolidating snapshots, the chain determines reading order (newest wins in conflicts) and which "Where We're Going" sections are stale.

## The problem

Snapshots may have `Superseded by: *(leave blank)*` even though they ARE later superseded by a snapshot in a different, parallel chain. This happens when:
- The second chain was written in a separate session and the author didn't revisit the earlier chain
- The snapshot was written as a "new topic" (`Supersedes: none — new topic`) but later became subsumed by a comprehensive snapshot

Taking `Superseded by: *(leave blank)*` at face value causes you to treat an intermediate snapshot as a terminal (authoritative) snapshot, merging its stale "Where We're Going" into the final document.

## Example

QuarkMind's 8-snapshot collection had three parallel chains:
- Chain A: 2026-04-06 → 2026-04-07-full-agent-loop ← `Superseded by: (blank)` ← WRONG
- Chain B: 2026-04-07-flow-economics → 2026-04-08-drools-goap ← `Superseded by: (blank)` ← WRONG
- Chain C: 2026-04-09-all-four-plugins → sc2-dispatch → e1-visualizer → e3-combat (ACTUAL terminal)

Chain A and Chain B's terminals both said "leave blank" but Chain C clearly superseded them all — it covered all four plugins and emulation, which subsumed everything in the earlier chains.

## The technique

Before treating any snapshot as authoritative:
1. Read the header block of **every** snapshot (dates + supersession fields) — not just those in the apparent chain
2. Draw all chains on paper or mentally
3. Cross-check: does a later snapshot **cover the same or broader scope** as an earlier chain's terminal?
   - If yes: the earlier terminal IS superseded, regardless of its blank field
4. Verify with dates: a later-dated snapshot covering broader scope almost certainly supersedes earlier ones

```bash
# Quick: read all snapshot headers at once
for f in docs/design-snapshots/*.md; do
  echo "=== $(basename $f) ==="; head -7 $f; echo
done
```

The topic field is the key signal: "All four R&D plugin seams complete" in a 2026-04-09 snapshot supersedes "Full agent loop complete" in a 2026-04-07 snapshot even if the latter says "Superseded by: (blank)".

## Why this is non-obvious

The "Superseded by" field looks authoritative — it was written by the same author at the time of the snapshot. Blank means "still current" in normal usage. The parallel chain problem only surfaces when you compare dates and topics across all snapshots simultaneously, which requires reading all headers upfront rather than following the chain links one-by-one.
