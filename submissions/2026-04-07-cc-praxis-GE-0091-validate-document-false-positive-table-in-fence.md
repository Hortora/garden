**Submission ID:** GE-0091
**Date:** 2026-04-07
**Project:** cc-praxis
**Type:** gotcha
**Stack:** cc-praxis skills repo, validate_document.py (Python), any type:skills project
**Score:** 11/15
**Suggested target:** tools/claude-code.md or a new tools/cc-praxis-tooling.md

---

## validate_document.py flags markdown tables inside fenced code blocks as corrupted

**Symptom:** Running `python3 scripts/validate_document.py <file>.md` returns:

```
❌ CRITICAL issues found in <file>.md:
  - Corrupted table at line N: Table header followed by prose instead of data row
```

The flagged line is a valid markdown table row inside a fenced code block
(e.g., ` ```markdown ``` `). The table itself is well-formed; the error is
a false positive.

**Context:** Any markdown document containing a markdown table *as an example
inside a fenced code block*. Common in design documents, documentation specs,
and any file that shows the format of an INDEX.md or similar.

### What was tried (didn't work)

- Checked the table column counts — all correct (header, separator, and data
  rows all have matching pipe counts)
- Checked for trailing spaces or encoding issues — none found
- Ran the validator on the fenced block in isolation — same error

### Root cause

`validate_document.py` does not correctly track code-fence state. It parses
markdown tables inside ` ```fenced blocks``` ` as if they were real markdown
tables in the document body. When the last table row appears immediately
before the closing ` ``` `, the validator sees the fence as "prose instead
of a data row" following the table, triggering the CRITICAL error.

### Fix

Add a blank line before the closing fence to break the validator's false
pattern match:

```markdown
| col1 | col2 |
|------|------|
| val  | val  |
          ← blank line here
```

This prevents the closing ``` from being parsed as "prose after a table row."

The real fix is to update validate_document.py to track code-fence state
and skip table validation for content inside fenced blocks. The false positive
blocks commits via the pre-commit hook.

### Why non-obvious

The error message points to a specific line number with content that *looks*
like a valid table row. Nothing in the error message indicates the issue is
the code fence context rather than the table itself. Developers will inspect
the table columns repeatedly before realising the fenced block is the problem.
The workaround (blank line) is counterintuitive — the table is correctly
formatted, you're adding "wrong" whitespace to fix a validator bug.

*Score: 11/15 · Included because: blocks commits via pre-commit hook; symptom
completely misleads about root cause; blank-line workaround is non-obvious ·
Reservation: specific to validate_document.py in cc-praxis*
