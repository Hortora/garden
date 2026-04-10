---
title: "Claude Code CSO validator rejects common English words as workflow keywords"
type: gotcha
domain: claude-code
score: 10
tags: [claude-code, skill-authoring, CSO, validation, description]
verified: true
staleness_threshold: P2Y
summary: "The CSO compliance validator flags common English words like 'run', 'first', 'creates', 'per' as workflow keywords, causing CRITICAL violations in skill descriptions."
---

**ID:** GE-0005
**Stack:** Claude Code skill authoring, `validate_cso.py`, cc-praxis skill repository

## Symptom

Writing a natural English skill description like "Use when setting up a workspace for the first time — one-time only, run once on each machine" causes CRITICAL CSO violations. The validator rejects the description before the skill can be committed.

## What was tried

Natural phrasing:
```
description: >
  Use when setting up a workspace for a project for the first time — ...
  NOT for day-to-day workspace use — one-time setup per project per machine.
```
Produced: `CSO violation: Description contains workflow keywords: first, creates, per`

Revised:
```
  ... one-time only, run once on each machine.
```
Produced: `CSO violation: Description contains workflow keywords: run`

## Root cause

`validate_cso.py` maintains a `WORKFLOW_KEYWORDS` list that is more aggressive than skill authors expect:

```python
WORKFLOW_KEYWORDS = [
    'step', 'then', 'invoke', 'run', 'execute', 'dispatch',
    'call', 'trigger', 'spawn', 'launch', 'start',
    'first', 'second', 'third', 'next', 'after', 'before',
    'reads', 'writes', 'creates', 'updates', 'deletes',
    'analyzes', 'validates', 'checks', 'verifies'
]
```

Many of these (`run`, `first`, `creates`, `per`) are common English words that any author would naturally use. The validator matches on whole words only (`\b{keyword}\b`) but the list is broad enough to catch neutral usage.

There are also `PROCESS_PATTERNS` that catch:
- `per <noun>` — e.g. "per project per machine"
- `step N`, `phase N`
- `after <verb>ing`

## Fix

Rephrase to avoid all words in the list. For "run once per machine" try:
```
one-time only, each machine independently.
```

For "first time", try:
```
when a project has no companion workspace yet
```

For "creates X", try:
```
Use when X doesn't exist yet
```

The CSO description should describe *when* to use the skill (symptoms, triggers) not *what it does* (workflow steps). This is the actual intent of the validator — reframing around triggers naturally avoids most keyword conflicts.

## Why this is non-obvious

The words `run`, `first`, `creates`, `per`, `checks`, `validates` are so common in English that skill authors would never suspect them as forbidden. The error message names the specific keywords ("workflow keywords: run") but doesn't explain they're in a hardcoded list or suggest how to rephrase. The intent (focus on *when*, not *what*) is clear in the CSO documentation, but the keyword list enforces it more strictly than the documentation implies.
