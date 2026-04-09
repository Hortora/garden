# Garden Submission

**Date:** 2026-04-09
**Submission ID:** GE-0156
**Type:** gotcha
**Source project:** hortora (garden maintenance session)
**Session context:** Updating GARDEN.md metadata using sed to replace lines containing `**Last assigned ID:**`
**Suggested target:** `tools/markdown.md` (existing)

---

## macOS `sed -i ''` silently empties a file when the pattern contains `**` (double asterisk)

**Stack:** macOS BSD sed (all versions), bash, markdown files
**Symptom:** After running `sed -i ''` to replace a line in a markdown file, the file becomes 0 bytes. No error is printed. Exit code is 0. The `&&`-chained next command (e.g. `head -5`) also produces no output because the file is empty.
**Context:** Editing a markdown file that contains lines starting with `**` (bold markdown syntax, e.g. `**Last assigned ID:** GE-0152`) using macOS BSD sed with a substitution pattern that includes `\*\*` in the search and `**` in the replacement.

### What was tried (didn't work)
```bash
sed -i '' 's/\*\*Last assigned ID:\*\* GE-0144/**Last assigned ID:** GE-0152/' GARDEN.md
# Result: GARDEN.md becomes 0 bytes, no error
```

### Root cause
macOS uses BSD sed, which differs from GNU sed in how it handles certain escape sequences and special characters in the replacement string. When the replacement contains unescaped `*` and `/` characters alongside markdown-style `**`, BSD sed can produce empty output — which `-i ''` faithfully writes to the file, replacing its entire contents with nothing. The command exits 0 because sed itself did not error; it just produced no output.

### Fix
Never use macOS `sed` for in-place editing of markdown files with `**` patterns. Use Python or the Write tool instead:

```python
python3 -c "
import pathlib
p = pathlib.Path('GARDEN.md')
p.write_text(p.read_text().replace(
    '**Last assigned ID:** GE-0144',
    '**Last assigned ID:** GE-0152'
))
"
```

Or read the file, modify in memory, and write back with the Write tool.

**Recovery:** If the file was under git, restore immediately:
```bash
git checkout HEAD -- GARDEN.md
```

### Why non-obvious
`sed -i ''` is a standard, trusted in-place editing idiom on macOS. It produces no error message when it empties the file. The symptom (0-byte file) looks like a permissions or disk issue, not a sed pattern problem. The connection between `**` in the pattern/replacement and silent empty output is not documented anywhere.

---

## Garden Score

| Dimension | Score (1–3) | Notes |
|-----------|-------------|-------|
| Non-obviousness | 3 | Exit 0, no error, trusted tool |
| Discoverability | 3 | Not documented; only findable by hitting it |
| Breadth | 2 | Affects anyone editing markdown with sed on macOS |
| Pain / Impact | 3 | Silent data loss; git is the only recovery path |
| Longevity | 2 | BSD sed behaviour is stable but Linux/GNU sed doesn't exhibit this |
| **Total** | **13/15** | |

**Case for inclusion:** Silent data loss from a trusted tool with no error signal; affects any session editing markdown metadata with sed on macOS; git recovery is non-obvious under pressure.
**Case against inclusion:** Somewhat specific to macOS + `**` combination.
