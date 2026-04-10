---
title: "Python json.dump ASCII-escapes em-dash as \\u2014, breaking literal string match"
type: gotcha
domain: python
score: 9
tags: [python, json, unicode, encoding, string-matching, em-dash]
verified: true
staleness_threshold: P5Y
summary: "json.dump() with default ensure_ascii=True converts em-dash (—) to \\u2014, so any tool or code doing literal string matching on the JSON file fails silently."
---

**ID:** GE-0006
**Stack:** Python `json` module, any version; Edit tool; string matching on JSON files

## Symptom

A JSON file written by Python contains `\u2014` where you expect `—`. Any tool doing literal string matching (Edit tool's `old_string`, `grep`, `str.replace`) against the actual em-dash character silently fails to find the target — the match returns no results, and the edit is not applied.

```python
import json
data = {"description": "Universal workflow — any project"}
with open("out.json", "w") as f:
    json.dump(data, f, indent=2)
# File contains: "description": "Universal workflow \u2014 any project"
# NOT: "description": "Universal workflow — any project"
```

## What was tried

- Edit tool with `old_string` containing literal `—` → "String not found" even though the text appears visually identical in the editor
- `grep "—" file.json` → no matches
- Visually inspecting the file appeared identical — both render the same in most terminals and editors

## Root cause

`json.dump()` defaults to `ensure_ascii=True`, which causes all non-ASCII characters to be replaced with their `\uXXXX` escape sequence. Em-dash (U+2264, `—`) becomes `\u2014`. The rendered output *looks* the same in most contexts (terminals, browsers, editors all render `\u2014` as `—`), but byte-level string matching fails.

## Fix

**Option 1 — Write with `ensure_ascii=False`:**
```python
json.dump(data, f, indent=2, ensure_ascii=False)
# File now contains literal: "description": "Universal workflow — any project"
```

**Option 2 — Manipulate via Python when string matching would fail:**
```python
with open("file.json") as f:
    data = json.load(f)
# Modify data dict directly — no string matching needed
data["plugins"].append(new_entry)
with open("file.json", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

**Option 3 — Search for the escaped form:**
```
old_string: "Universal workflow \u2014 any project"
```

## Why this is non-obvious

The em-dash renders identically in the terminal, editor, and browser whether stored as `—` or `\u2014`. There's no visual signal that the byte representation differs. The default `ensure_ascii=True` is a legacy behaviour for maximum compatibility, but it silently transforms characters that "look fine" in ways that break tools operating at the byte level. A developer who wrote the file in Python and opens it in an editor sees no difference — only the matching failure reveals the problem.
