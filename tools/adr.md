# ADR Tooling Gotchas and Techniques

---

## MADR `Date:` field is never auto-populated — always empty unless manually set

**ID:** GE-0044
**Stack:** MADR format (any version), `adr` skill (cc-praxis), any ADR tooling that generates MADR templates
**Symptom:** Grepping `^Date:` across all ADRs in a repo returns nothing — all ADRs have the literal placeholder `Date: YYYY-MM-DD` or a blank value. Tooling that reads ADR dates silently produces no output.
**Context:** Any tooling that reads ADR `Date:` fields expecting creation dates — the field is a placeholder, never auto-populated.

### Description

MADR templates include a `Date:` field in the header:

```markdown
# ADR-0001: Some Decision

Date: YYYY-MM-DD
Status: Accepted
```

The `YYYY-MM-DD` is a literal placeholder. No MADR tooling (including `adr-tools`, the cc-praxis `adr` skill, or manual template copying) fills this in automatically. The field remains literally `Date: YYYY-MM-DD` or is left blank unless the author manually types the date.

The git commit date of the ADR file IS available and reliable as a proxy, but requires a separate `git log` lookup — it's not in the document itself.

### Fix / Workaround

**To get the actual creation date of an ADR from git:**

```bash
# Date the file was first committed
git log --follow --diff-filter=A --format="%ad" --date=short -- docs/adr/0001-*.md

# All ADRs with their creation dates
for f in docs/adr/*.md; do
  date=$(git log --follow --diff-filter=A --format="%ad" --date=short -- "$f" 2>/dev/null | tail -1)
  echo "$date  $f"
done | sort
```

**To detect which ADRs have a manually-set Date: field:**

```bash
grep "^Date:" docs/adr/*.md | grep -v "YYYY-MM-DD"
```

Returns nothing if all are still placeholder values.

### Why it's not obvious

The MADR template documentation shows `Date: YYYY-MM-DD` as if it's a required field, implying it would be filled in. There's no note in any MADR documentation saying "you must fill this in yourself" — it reads like a metadata field that tools handle. Developers building on ADR date metadata naturally assume the field is populated and only discover it's empty when their tooling returns no results.

### Caveats

- Git commit date is a reliable proxy but requires `git log` — it's not in the document
- Some teams have CI hooks that auto-populate the Date field on commit; this only applies to teams that haven't set that up
- The `adr-tools` CLI has its own template mechanism that may populate Date on some platforms — test your specific setup

*Score: 13/15 · Included because: silent failure — grep returns nothing with no error; natural assumption that Date: is auto-populated is wrong; git log workaround is non-obvious · Reservation: none identified*
