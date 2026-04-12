# Hortora Gotchas

## `validate_garden.py` strip_code_fences regex silently hides all IDs after a literal triple backtick in entry body text

**ID:** GE-20260410-5fd0c3
**Stack:** Hortora validate_garden.py (any version as of 2026-04-10)
**Symptom:** `ERROR: Index references GE-XXXX ('title') but no matching **ID:** in any garden file` — for entries that clearly exist. `grep` confirms `**ID:** GE-XXXX` is in the file. Re-running produces the same error.
**Context:** A garden entry whose body text contains a literal triple-backtick sequence as prose (e.g. describing "the closing triple-backtick fence marker") in the same file as entries the validator cannot find.

**Root cause:** `strip_code_fences` uses `re.sub(r'```.*?```', '', content, flags=re.DOTALL)`. A literal triple-backtick sequence in prose is treated as a fence opener. The next real fence in the file becomes the closer, stripping everything between — including all `**ID:**` lines that follow. Those entries become invisible to the validator.

```python
# The offending regex in strip_code_fences:
re.sub(r'```.*?```', '', content, flags=re.DOTALL)
# Non-greedy but still matches literal ``` in prose as a fence delimiter
```

**Fix:** In entry body text, describe fence markers in words rather than literal triple-backtick sequences: "closing fence marker" instead of the actual characters. No validator change needed — the regex works as designed; the issue is prose that accidentally matches the fence pattern.

**Recovery:** Change the prose, re-run the validator — the hidden IDs reappear immediately.

**Why non-obvious:** The error message says "no matching **ID:**" — implying the entry is absent. The actual entry exists and is correct. The connection between a literal triple-backtick sequence in prose many lines earlier and IDs being invisible requires reading the validator source.

**See also:** GE-0136 (false positives from IDs appearing inside code blocks — different failure mode of the same validator)

*Score: 12/15 · Non-obvious symptom that looks like a missing entry but is a regex false positive; only discoverable by reading the validator source · Reservation: specific to Hortora's validate_garden.py*

---
