# Data Structures and Algorithm Techniques

---

## Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus

**ID:** GE-0034
**Stack:** Any system accumulating entries that need deduplication (language-agnostic)
**Labels:** `#strategy` `#deduplication` `#algorithm`
**What it achieves:** Periodic deduplication sweeps that scale with new entries, not total entries — re-checking already-verified pairs costs zero.
**Context:** Any system where: (a) entries accumulate over time, (b) deduplication is expensive (requires reading and comparing content), and (c) you can't afford to run a full pairwise comparison every time.

### The technique

Maintain a sparse log of pairs that have already been compared, recording the result:

```markdown
| Pair            | Result              | Date       | Notes            |
|-----------------|---------------------|------------|------------------|
| ID-001 × ID-002 | distinct            | 2026-04-06 |                  |
| ID-001 × ID-003 | related             | 2026-04-06 | cross-referenced  |
| ID-004 × ID-005 | duplicate-discarded | 2026-04-06 | ID-004 kept       |
```

On each deduplication sweep:
1. Enumerate all pairs within the relevant group (category, type, etc.)
2. Subtract pairs already in the log
3. Process only the remainder — the unchecked pairs
4. Add results to the log

As the corpus grows from N to N+K entries, each new entry creates K new pairs to check (against the K existing entries in its category), not N² total. Pairs checked once are never re-checked unless one entry is revised.

```python
# Conceptual implementation
all_pairs = {(a, b) for a in entries for b in entries if a < b}
checked_pairs = read_pair_log()
unchecked = all_pairs - checked_pairs
for pair in unchecked:
    result = compare(pair)
    log_pair(pair, result)
```

### Why this is non-obvious

The instinct is to run a full pairwise comparison on every sweep ("check everything to be sure") or to use a fixed schedule ("check every N days"). Both scale poorly:
- Full pairwise: O(N²) cost grows quadratically; unusable at scale
- Fixed schedule: doesn't account for activity level; quiet periods waste effort, busy periods miss checks

The sparse log makes the check incremental. Each sweep's cost is proportional to new entries since the last sweep, not the total corpus size. The log itself is the memory of what's been verified.

### When to use it
- Knowledge repositories that accumulate entries over time (wikis, gotcha gardens, pattern libraries)
- Code deduplication systems where comparison is expensive
- Any "have I seen this before?" problem at scale where comparison cost is non-trivial

Limitation: requires a stable identifier for each entry. Works best when entries are discrete and identifiable, not streaming or ephemeral.

**See also:** GE-0035 for the complementary pattern of when to trigger exhaustive sweeps.

*Score: 13/15 · Included because: directly solves the "deduplication becomes too expensive to run" problem every growing knowledge system eventually hits; pattern is simple once stated but not reached intuitively · Reservation: known in caching/memoization literature; skilled developer who thinks carefully might arrive at it independently*

---

## Trigger exhaustive sweeps by activity count, not time, to match cost to actual need

**ID:** GE-0035
**Stack:** Any system with expensive periodic maintenance operations (language-agnostic)
**Labels:** `#strategy` `#algorithm` `#workflow`
**What it achieves:** Exhaustive sweeps that run when genuinely needed — triggered by accumulated activity, not arbitrary calendar intervals.
**Context:** Systems where a maintenance operation (deduplication, consistency check, index rebuild) is too expensive to run on every update but still needs to run periodically.

### The technique

Track an activity counter alongside a threshold. Increment the counter on each update. When the counter reaches the threshold, trigger the exhaustive operation and reset.

```markdown
# In a metadata header or config file:
**Entries merged since last sweep:** 7
**Drift threshold:** 10
```

On each update:
1. Check counter against threshold
2. If counter >= threshold: propose the exhaustive sweep (run now / defer / skip)
3. If accepted: run the sweep, reset counter to 0
4. If deferred: continue, counter stays at threshold (will prompt again next update)
5. If skipped: continue, reset counter (suppress for this cycle)
6. Increment counter by the number of items processed in this update

```python
# Conceptual check at start of each merge/update batch
entries_since_sweep = read_counter()
threshold = read_threshold()

if entries_since_sweep >= threshold:
    decision = prompt_user("Run exhaustive sweep? (yes/defer/skip)")
    if decision == "yes":
        run_sweep()
        reset_counter()
    elif decision == "skip":
        reset_counter()
    # defer: leave counter at threshold, prompt again next time
```

### Why this is non-obvious

Two common alternatives both have flaws:
- **Every update:** too expensive; users skip or disable maintenance entirely
- **Fixed schedule (daily/weekly):** ignores actual activity — a quiet period wastes effort; a burst of activity may not trigger a sweep until the next scheduled run, leaving consistency gaps

Activity-based triggering matches cost to need. If 10 entries are the threshold and the corpus is quiet for a month, no sweep runs. If 10 entries arrive in one day, the sweep triggers immediately.

The key implementation detail: the counter tracks *activity since last sweep*, not total activity. Resetting on sweep completion is what makes it incremental.

### When to use it
- Knowledge repositories with periodic deduplication or consistency checks
- Search index rebuilds too expensive to run on every update
- Any maintenance operation where "run when needed" is more appropriate than "run on schedule"
- CI/CD: trigger full integration test suites after N commits rather than on every push

**See also:** GE-0034 for the sparse pair log pattern that makes the sweep itself efficient.

*Score: 12/15 · Included because: a clean generalisation of the database vacuuming / GC trigger pattern applied to knowledge management; named and concrete · Reservation: experienced developers familiar with database internals will recognise the pattern immediately*
