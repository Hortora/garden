**Submission ID:** GE-0075
**Date:** 2026-04-07
**Project:** remotecc
**Type:** gotcha
**Suggested target:** `tools/tmux.md` (new file — header: `# tmux Gotchas and Techniques`)

## tmux capture-pane Output Ends with \n — split() Gives paneHeight+1 Elements

**Stack:** tmux 3.x, Java (any JVM language using String.split), any language that splits capture-pane output by newline

**Symptom:** Row arithmetic using `lines.length - paneHeight + cursorY` gives the wrong row by exactly 1. An xterm.js cursor positioning escape lands one row below the intended target. Visually: typed input appears one row below the prompt instead of on the prompt line.

**Context:** When using `tmux capture-pane -p -S -N` output and splitting on `\n` with a negative limit (`raw.split("\n", -1)` in Java, `split('\n')` with keep-empty in Python, etc.), the captured output always ends with `\n`, producing one extra empty string at the end of the array.

**What was tried:**
- Calculating `paneRowInCapture = lines.length - paneHeight + paneCursorY` — off by 1
- Wondered if the pane height was wrong — it was correct
- Logging `lines.length` vs `paneHeight` — differed by exactly 1

**Root cause:** `tmux capture-pane -p` output is `row1\nrow2\n...rowN\n` — a trailing newline after every row including the last. When split by `\n` with an empty-trailing-element mode, this yields `N+1` elements where the last is `""`. The effective capture size is `lines.length - 1` (if the last element is empty), not `lines.length`.

**Fix:**
```java
// Java
int captureSize = lines[lines.length - 1].isEmpty()
    ? lines.length - 1 : lines.length;
int paneRowInCapture = (captureSize - paneHeight) + paneCursorY;
int xtermsRow = paneRowInCapture - firstContent + 1; // 1-indexed
```
```python
# Python
lines = raw.split('\n')
if lines and lines[-1] == '':
    lines = lines[:-1]
capture_size = len(lines)
```

**Why non-obvious:** The trailing newline is invisible in log output. `len(lines)` looks correct at a glance. The off-by-one only manifests as a visual cursor position error, which is easy to attribute to other causes (wrong pane height, wrong cursor reading, etc.).

*Score: 12/15 · Included because: silent arithmetic error with misleading symptom, stable tmux behaviour · Reservation: slightly language-specific in the fix, but root cause is universal*
