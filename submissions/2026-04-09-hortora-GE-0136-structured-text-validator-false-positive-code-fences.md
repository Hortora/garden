# Garden Submission

**Date:** 2026-04-09
**Submission ID:** GE-0136
**Type:** gotcha
**Source project:** hortora (soredium validate_garden.py)
**Session context:** Building a garden entry validator that scans markdown files for structured markers
**Suggested target:** `tools/markdown.md` (existing)

---

## Structured Text Validators Produce False Positives from Markers Inside Fenced Code Blocks

**Stack:** Python (any version), `re` module, any structured markdown validator
**Symptom:** A validator scanning for a structured marker pattern (e.g. `**ID:** GE-XXXX`, `**Status:** DONE`) reports false positives — entries that appear to match the pattern but are actually example values inside fenced code blocks. No error is raised; the validator silently misclassifies content.

**Context:** Any script that uses regex to scan markdown files for structured markers, where those same markers may appear as example values inside ` ``` ` fenced code blocks (e.g. documentation showing what the marker looks like, or gotcha entries showing broken vs fixed output).

### What was tried (didn't work)
- `re.finditer(r'^\*\*ID:\*\*\s+(GE-\d{4})', content, re.MULTILINE)` — matches inside code blocks too, because `^` matches start of any line including lines within fenced blocks

### Root cause
`re.MULTILINE` makes `^` match at the start of every line in the string, regardless of whether that line is inside a fenced code block. Python's regex has no awareness of markdown structure. A line like `` **ID:** GE-0042 `` inside a ` ``` ` block is indistinguishable from a real marker line.

### Fix
Strip fenced code blocks before running the regex:

```python
import re

def strip_code_fences(content: str) -> str:
    """Remove content inside fenced code blocks to avoid false positives."""
    return re.sub(r'```.*?```', '', content, flags=re.DOTALL)

# Then scan the stripped content
content_stripped = strip_code_fences(path.read_text())
for m in re.finditer(r'^\*\*ID:\*\*\s+(GE-\d{4})', content_stripped, re.MULTILINE):
    ge_id = m.group(1)
    # ...
```

`re.DOTALL` makes `.` match newlines, so the pattern captures multi-line code blocks correctly.

### Why non-obvious
The validator works correctly for all "real" structured content. It only fails when the same structured marker appears as an example in documentation — which is common in gotcha entries that show broken vs fixed output. The false positive looks exactly like a real match (same format, same line structure), so the error message points at a valid-looking line with no indication that a code block is involved.

---

## Garden Score

| Dimension | Score (1–3) | Notes |
|-----------|-------------|-------|
| Non-obviousness | 3 | MULTILINE + code fences interaction is not obvious |
| Discoverability | 2 | Findable in regex docs but not called out |
| Breadth | 2 | Affects any markdown validator with similar patterns |
| Pain / Impact | 2 | Reports false errors, breaks CI |
| Longevity | 3 | Fundamental markdown/regex mismatch — permanent |
| **Total** | **12/15** | |

**Case for inclusion:** Cross-project pattern — affects any structured markdown validator. Fix is non-obvious (stripping fences, not just adjusting the regex).
**Case against inclusion:** None identified.
