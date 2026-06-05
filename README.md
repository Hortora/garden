# Hortora Knowledge Garden

A cross-project library of hard-won technical knowledge — shared across all
projects and Claude sessions on this machine.

Three kinds of entries:

- **Gotchas** — bugs that silently fail, behaviours that contradict
  documentation, workarounds that took hours to find
- **Techniques** — genuinely novel tricks, approaches, and patterns that work
  in non-obvious ways; things a skilled developer wouldn't naturally reach for
  but would immediately value once shown
- **Undocumented** — behaviours only discoverable via source code, trial and
  error, or commit history; features that work but have no documentation

**Not** a tutorial library. **Not** a documentation mirror. **Not** a log of
expected errors with obvious fixes. Every entry passed the bar: a skilled
developer familiar with the technology would still have been surprised by this.

---

## Local Setup

Clone once per machine to the canonical path:

```bash
git clone git@github.com:Hortora/garden.git ~/.hortora/garden
```

Install the autonomous dedup agent (post-commit hook + CLAUDE.md + settings):

```bash
cd ~/.hortora/garden
~/claude/hortora/soredium/scripts/garden-agent-install.sh
```

---

## Structure

```
~/.hortora/garden/
├── README.md                 ← this file
├── GARDEN.md                 ← the index (start here; read entries on demand)
├── SCHEMA.md                 ← entry format and field definitions
├── jvm/                      ← JVM / Java universal knowledge
│   ├── GE-20260421-28c521.md
│   └── ...
├── tools/                    ← cross-language tool gotchas (git, docker, tmux)
│   ├── GE-0010.md
│   └── ...
├── quarkus/                  ← Quarkus-specific (frozen; new entries go to jvm/)
├── submissions/              ← incoming entries awaiting dedup and placement
│   └── YYYY-MM-DD-proj-slug.md
└── <domain>/                 ← additional domain directories
    └── GE-<id>.md
```

Entry files are named by GE-ID: `GE-YYYYMMDD-6hex.md` (current scheme) or
`GE-NNNN.md` (legacy). The ID is stable — filenames never change after creation.

---

## How to Use This Garden

### The right starting point is always GARDEN.md

`GARDEN.md` is the index — small enough to load into a context window, with
one line per entry. It has sections by domain and by symptom type.

**Load GARDEN.md first. Read entry files only when GARDEN.md points you there.**

### Surgical reads — avoid loading entire files

Once GARDEN.md points you to a file, you usually want one entry, not the whole
file. Use targeted reads:

```bash
# Find which files contain entries about a keyword
grep -r "dispatch_async" ~/.hortora/garden --include="*.md" -l

# Read just the entry matching a title
grep -A 40 "## GCD main queue" ~/.hortora/garden/jvm/GE-20260421-28c521.md

# Find entries by domain
grep -r "^domain: jvm" ~/.hortora/garden --include="*.md" -l

# Find entries by type
grep -r "^type: gotcha" ~/.hortora/garden --include="*.md" -l
```

The `grep -A N` flag reads N lines after the match — enough for one entry
without loading the surrounding file. Start with `-A 40`; increase if cut off.

---

## How Entries Get Added

Entries are captured via the `forage` skill in Claude Code during active sessions.
Contributors never read existing garden files before submitting — they write a
self-contained submission and let the `harvest` skill handle deduplication and
placement.

```bash
# Check pending submissions
ls ~/.hortora/garden/submissions/

# Process them (run in a dedicated session)
# Ask Claude: "harvest the garden submissions" — invokes the harvest skill
```

### Entry format

Each entry is a markdown file with YAML frontmatter:

```yaml
---
id: GE-20260421-28c521
title: "Short descriptive title"
type: gotcha           # gotcha | technique | undocumented
domain: jvm            # jvm | tools | quarkus | ...
stack: "Quarkus 3.x, Java 21"
tags: [hibernate, lazy-loading]
score: 8               # 1–15; higher = more surprising / impactful
submitted: 2026-04-21
---

## Title repeated here

**What it is:** One sentence.
**How discovered:** How you found it.

### Description

...

### Fix / How to use

...
```

---

## Token-Efficient Usage Patterns

### Pattern 1: Debugging — search by symptom

```
1. Load GARDEN.md
2. Scan "By Symptom Type → Silent failures" (or relevant category)
3. Find matching entry title and file
4. grep -A 40 "<title>" <file>
```

Cost: GARDEN.md (small) + one entry section (~40 lines).

### Pattern 2: Technology lookup

```
1. Load GARDEN.md
2. Scan "By Domain → jvm" (or relevant domain)
3. Skim one-line descriptions
4. grep -A 40 "<title>" <file>
```

### Pattern 3: Broad keyword search

```bash
# Cheap — filenames only
grep -r "keyword" ~/.hortora/garden --include="*.md" -l

# Then read the matching entry
grep -A 40 "## <title>" <matching-file>
```

### Pattern 4: Submitting new knowledge

```
1. Recall from conversation context — free, no reads needed
2. Use the forage skill: CAPTURE with the specific content
3. git commit — post-commit hook runs the dedup agent automatically
```

Cost for submission: near zero. No existing garden files read.

---

## Maintenance

| Task | Frequency | How |
|------|-----------|-----|
| Process submissions | Every 3–5 submissions | `harvest` skill — DEDUPE |
| Staleness review | Periodically | `harvest` skill — REVIEW |
| Split large domains | As needed | Create subdomain dirs, update GARDEN.md |
| Mark fixed bugs | When noticed | Add `**Resolved in:** vX.Y` to entry |

**Never delete entries** — older versions of tools still need them. Mark fixed
bugs with `**Resolved in:** vX.Y` at the end of the entry body.

---

## The Garden Is Useful If

Six months from now, a Claude session can find the relevant entry faster than
searching the web or rereading conversation history — and read only that entry,
not the whole file.
