# Text Processing Techniques

---

## Walk text character-by-character tracking quote state to skip keyword matching inside strings

**ID:** GE-0132
**Stack:** Python (general pattern — language-agnostic)
**Labels:** `#pattern` `#parsing`
**What it achieves:** Prevents a keyword-insertion regex from firing inside quoted string literals, where the keyword is part of content rather than language structure.
**Context:** Reformatting structured text (e.g. DRL, SQL, shell scripts, template languages) by inserting `\n` before keywords. The keywords also appear inside quoted strings, where they must not be modified.

### The technique

Instead of a single regex substitution, walk character-by-character, tracking quote state. Only apply the keyword replacement when outside quotes:

```python
result = []
in_quote = False
i = 0
while i < len(text):
    ch = text[i]
    if ch == '"':
        in_quote = not in_quote
        result.append(ch)
        i += 1
        continue
    if not in_quote:
        m = KEYWORD_RE.match(text, i)
        if m:
            kw = m.group(1)
            if result and result[-1] != '\n':
                result.append('\n')
            result.append(kw)
            if kw in LINE_ALONE_KEYWORDS:
                result.append('\n')
            i = m.end()
            continue
    result.append(ch)
    i += 1
return ''.join(result)
```

### Why this is non-obvious
The obvious approach is `re.sub(keyword_pattern, replacement, text)`. This works until the keyword appears inside a quoted string — at which point the regex has no way to know it's in string context without lookbehind patterns that become arbitrarily complex. The character walk is O(n) and handles any nesting depth. Extend with backslash tracking for escape sequences, or a quote-style stack for multiple quote types.

### When to use it
Any text transformation that inserts structural markers (newlines, delimiters, tags) at keyword boundaries in a language where those keywords can also appear inside string literals. Common cases: DRL, SQL, shell scripts, template languages, configuration DSLs.

*Score: 11/15 · Included because: character-walk pattern for quote-aware parsing is non-obvious; prevents regex false positives inside strings; O(n) and extendable · Reservation: experienced developers may know this as a basic lexer pattern*
