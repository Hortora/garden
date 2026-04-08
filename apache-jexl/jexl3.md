# Apache JEXL3 Gotchas

---

## JEXL3 `${var}` inside single-quoted string literals is not interpolated — literal text output

**Stack:** Apache Commons JEXL3 3.3 (confirmed; applies to all 3.x versions — ${} in single-quoted strings has never been interpolated)
**Symptom:** `'Join${i}Second<END, DS, A>'` in a JEXL expression produces the literal string `Join${i}Second<END, DS, A>` — `i` is never substituted. No error is thrown.
**Context:** Any JEXL expression that tries to embed a variable reference inside a string literal using `${}` syntax. Common when building class name strings dynamically, e.g. in Permuplate `@PermuteReturn(typeArgs = "'Join${i}Second<...'")`.

### What was tried
- `'Join${i}Second<END, DS, ' + typeArgList(1, i, 'alpha') + '>, DS'` — literal `${i}` in output; the variable substitution inside the string literal was silently ignored

### Root cause

JEXL3's `${...}` interpolation is a **top-level expression feature only**. When JEXL evaluates an expression like `${i + 1}`, the `${}` wrapper signals "evaluate this as a JEXL expression and substitute the result". But inside a single-quoted string literal, JEXL treats all content verbatim — no scanning for `${}` patterns occurs. The string is returned as-is.

This is fundamentally different from how most other template languages work: Groovy GStrings, Kotlin string templates, JavaScript ES6 template literals, and Python f-strings all support interpolation inside string literals. JEXL intentionally does not.

### Fix

Use string concatenation to combine the variable with string fragments:

```java
// WRONG — ${i} inside single quotes is literal text:
typeArgs = "'Join${i}Second<END, DS, ' + typeArgList(1, i, 'alpha') + '>, DS'"

// CORRECT — concatenate the variable at expression level:
typeArgs = "'Join' + i + 'Second<END, DS, ' + typeArgList(1, i, 'alpha') + '>, DS'"
```

For i=2, the correct form produces: `Join2Second<END, DS, A, B>, DS` ✓

### Why this is non-obvious

The `${}` syntax is universal in template languages — Groovy, Kotlin, JavaScript, Python, shell, Thymeleaf, etc. JEXL is the rare exception where `${}` only works at the top level of the expression, never inside string literals. There is no error; the output simply contains the literal `${i}` text, which can be mistaken for a downstream problem rather than a JEXL evaluation issue.
