# Knowledge Garden

A cross-project, machine-wide library of hard-won technical knowledge — shared
across all projects and Claude sessions on this machine.

Two kinds of entries:

- **Gotchas** — bugs that silently fail, behaviours that contradict
  documentation, workarounds that took hours to find
- **Techniques** — genuinely novel tricks, approaches, and patterns that work
  in non-obvious ways; things a skilled developer wouldn't naturally reach for
  but would immediately value once shown

**Not** a tutorial library. **Not** a documentation mirror. **Not** a log of
expected errors with obvious fixes. Every entry passed the bar: a skilled
developer familiar with the technology would still have been surprised by this.

---

## Structure

```
~/claude/knowledge-garden/
├── README.md                 ← this file (orientation, not indexed)
├── GARDEN.md                 ← the index (load this; read entries on demand)
├── SKILL-SPEC.md             ← spec for the garden skill (for Claude Code)
├── submissions/              ← incoming entries from any Claude session
│   └── YYYY-MM-DD-proj-slug.md
├── macos-native-appkit/      ← technology-specific entry files
├── java-panama-ffm/
├── graalvm-native-image/
├── quarkus/
├── tools/                    ← cross-language tool gotchas (tmux, git, docker)
└── <tech-category>/
    └── <topic>.md
```

---

## How to Use This Garden

### The right starting point is always GARDEN.md

`GARDEN.md` is the dual index — small enough to load into a context window,
with one line per entry. It has two sections:

- **By Technology** — find entries by what you're working with
- **By Symptom Type** — find entries by what you're experiencing (silent
  failure, contradicts docs, JVM-vs-native, symptom misleads, etc.)

**Load GARDEN.md first. Read entry files only when GARDEN.md points you there.**

### Surgical reads — avoid loading entire files

Once GARDEN.md points you to a file, you usually want one entry from it, not
the whole file. Use targeted reads rather than loading everything:

```bash
# Read just the entry matching a title (gotcha or technique)
grep -A 40 "## GCD main queue" macos-native-appkit/appkit-panama-ffm.md

# Read just the "Fix" section of a specific entry
grep -A 20 "## GCD main queue" macos-native-appkit/appkit-panama-ffm.md \
  | grep -A 15 "### Fix"

# Find which file contains entries about a keyword
grep -r "dispatch_async" . --include="*.md" -l

# Find entries by tag
grep -r "#silent-failure" . --include="*.md"

# Count entries in a file before deciding whether to load it
grep -c "^## " macos-native-appkit/appkit-panama-ffm.md
```

The `grep -A N` flag ("after N lines") is your primary tool for reading a
section without loading the surrounding file. Start with `-A 40` for a typical
entry; increase if the output is cut off.

### When files get large — splitting strategy

A technology file should be split when loading it to find one entry would be
wasteful. The threshold is roughly 400–500 lines, or when the file has grown
beyond about 8–10 entries.

**Splitting pattern:**

1. Create a subdirectory for the technology if not already split
2. Split by sub-topic, not alphabetically:
   - `appkit-input.md` — keyboard, focus, NSTextField gotchas
   - `appkit-webkit.md` — WKWebView gotchas
   - `appkit-layout.md` — NSSplitView, layout, event routing
3. Update GARDEN.md links to point to the new files — the index always reflects
   where entries actually live
4. The old file can be archived or removed once links are updated

The index (`GARDEN.md`) never needs structural changes — it just points to
wherever the entries live. Splitting a file is maintenance-free as long as
GARDEN.md is updated.

**Cross-references within and between files:**

If two entries are related, add a one-line note at the end of each:

```markdown
*See also: [Related title](../other-file.md#anchor)*
```

Keep cross-references minimal — only when the connection is genuinely useful
for diagnosis, not for completeness. One cross-reference is useful; ten is noise.

---

## How Entries Get Added

Claude sessions use the `garden` skill to submit entries. **Submitting Claudes
never read existing garden files** — they write a self-contained submission to
`submissions/` and let a dedicated MERGE session handle deduplication and placement.

```
submissions/YYYY-MM-DD-<project>-<slug>.md
```

Each submission includes a "Suggested target" hint for the merge Claude.

**To merge pending submissions:**

```bash
ls ~/claude/knowledge-garden/submissions/   # check what's pending
# then ask Claude: "merge the garden submissions"
```

---

## Token-Efficient Usage Patterns

### Pattern 1: Debugging — search by symptom

Something silently fails. You don't know the cause yet.

```
1. Load GARDEN.md
2. Scan "By Symptom Type → Silent failures"
3. Find matching entry title and file
4. grep -A 40 "<title>" <file.md>
```

Cost: GARDEN.md (small) + one entry section (~40 lines). Rest of file: never loaded.

### Pattern 2: Technology lookup

You're working with Quarkus and hit a strange behaviour.

```
1. Load GARDEN.md
2. Scan "By Technology → Quarkus"
3. Skim one-line descriptions for the relevant entry
4. grep -A 40 "<title>" <file.md>
```

### Pattern 3: Broad keyword search

You don't know which section applies.

```bash
# Find which files mention this keyword (cheap — filenames only)
grep -r "keyword" ~/claude/knowledge-garden/ --include="*.md" \
  -l --exclude-dir=submissions

# Read the relevant entry from the matching file
grep -A 40 "## <matching title>" <file>
```

`grep -l` returns filenames only — extremely cheap. The entry read is surgical.

### Pattern 4: Submitting new knowledge

At the end of a debugging session or after discovering a novel technique.

```
1. Recall from conversation context — free, no reads
2. Write submissions/YYYY-MM-DD-<project>-<slug>.md
3. git commit
4. MERGE happens in a dedicated session later
```

Cost for submission: near zero. No existing garden files read.

### Pattern 5: Reading without loading the full file

When you need more than one entry from a file but not all of it:

```bash
# List all entry titles in a file (to decide which ones to read)
grep "^## " macos-native-appkit/appkit-panama-ffm.md

# Read entries 3 and 4 only (skip to line N, read M lines)
sed -n '80,160p' macos-native-appkit/appkit-panama-ffm.md

# Read from a specific entry to the next entry separator
awk '/^## GCD main queue/,/^---$/' macos-native-appkit/appkit-panama-ffm.md
```

The `awk` pattern is particularly useful: it reads from an entry's `##` header
to the `---` separator that follows it, giving you exactly one entry without
knowing line numbers.

---

## Maintenance

| Task | Frequency | Who |
|------|-----------|-----|
| Process submissions | Every 3–5 submissions | MERGE session |
| Update GARDEN.md index | After MERGE | MERGE session |
| Split large files (>400 lines) | As needed | MERGE session |
| Add "Resolved in: vX.Y" to fixed bugs | When noticed | Any session |

**Never delete entries** — older versions of tools still need them. Mark fixed
bugs with `**Resolved in:** vX.Y` at the end of the entry.

---

## The Garden Is Useful If

Six months from now, a Claude session can find the relevant entry faster than
searching the web or rereading conversation history — and read only that entry,
not the whole file.
