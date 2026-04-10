**Submission ID:** GE-20260410-5fd0c3
**Type:** gotcha
**Suggested target:** tools/hortora.md (new)

## `validate_garden.py` strip_code_fences regex silently hides all IDs after a literal triple backtick in entry body text

**Stack:** Hortora validate_garden.py (any version as of 2026-04-10)

**Symptom:** `ERROR: Index references GE-XXXX ('title') but no matching **ID:** in any garden file` — for entries that clearly exist. `grep` confirms `**ID:** GE-XXXX` is in the file. Re-running the validator produces the same error.

**Context:** A garden entry whose body text contains a literal ` ``` ` as prose — e.g., describing "the closing ` ``` ` fence marker" — in the same file as the entries the validator cannot find.

**Root cause:** `strip_code_fences` uses `re.sub(r'```.*?```', '', content, flags=re.DOTALL)`. A literal ` ``` ` in prose text is treated as a fence opener. The next real ` ``` ` in the file becomes the closer, stripping everything between — including all `**ID:**` lines that follow. Those entries become invisible to the validator.

**Fix:** In entry body text, describe fence markers in words rather than literal backticks: "closing fence marker" instead of ` ``` `. No validator change needed — the regex is working as designed; the issue is prose that accidentally matches the fence pattern.

```python
# The offending regex in strip_code_fences:
re.sub(r'```.*?```', '', content, flags=re.DOTALL)
# Non-greedy but still matches literal ``` in prose as a fence delimiter
```

**Recovery:** Once the prose is changed, re-run the validator — the hidden IDs reappear immediately.

**Why non-obvious:** The error message says "no matching **ID:**" — implying the entry is absent. The actual entry exists and is correct. The connection between a literal ` ``` ` in prose text many lines earlier and IDs being invisible to the validator requires reading the validator source to understand.

*Score: 12/15 · Non-obvious symptom that looks like a missing entry but is a regex false positive; only discoverable by reading the validator source · Reservation: specific to Hortora's validate_garden.py*
