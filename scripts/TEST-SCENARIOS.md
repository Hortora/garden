# Garden System — Test Scenarios

Happy paths and edge cases for the ID system, duplicate detection, and DEDUPE.
Use these to verify the workflow is working correctly after changes.

---

## Scenario 1: First-ever submission (happy path)

**Setup:** Empty garden, GARDEN.md counter at GE-0000.

**Steps:**
1. CAPTURE: read counter → GE-0000
2. Increment → assign GE-0001
3. Update GARDEN.md: `Last assigned ID: GE-0001`
4. Write submission as `YYYY-MM-DD-project-GE-0001-slug.md` with `**Submission ID:** GE-0001`
5. Commit: submission file + GARDEN.md

**Expected:**
- GARDEN.md counter: GE-0001
- Submission file exists with correct ID in filename and header
- No CHECKED.md entries yet
- `validate_garden.py` passes (warning about missing index entry is acceptable pre-merge)

---

## Scenario 2: Sequential submissions, no duplicates

**Setup:** Counter at GE-0001, one existing entry GE-0001 in garden.

**Steps:**
1. CAPTURE submission A: reads GE-0001, assigns GE-0002, updates counter, commits
2. CAPTURE submission B: reads GE-0002, assigns GE-0003, updates counter, commits

**Expected:**
- Counter at GE-0003
- Two submission files: `...-GE-0002-...md` and `...-GE-0003-...md`
- Light duplicate check: neither flagged (different technology)

---

## Scenario 3: Submission conflicts with existing entry (CAPTURE catch)

**Setup:** Garden has GE-0003 "lxml encoding detection" in `tools/`.

**Steps:**
1. New submission about lxml encoding — same technology
2. CAPTURE Step 1b: scans index, finds GE-0003 with similar title
3. Flags to user: "Looks similar to GE-0003 — same thing or different?"
4. User says: same thing → stop, offer REVISE targeting GE-0003

**Expected:**
- No new GE-ID assigned (stopped before Step 0 increments)
- OR: if GE-ID was already assigned before the check flagged it — REVISE submission written with `**Target ID:** GE-0003` and its own `**Submission ID:** GE-XXXX`

---

## Scenario 4: MERGE catches duplicate (medium check)

**Setup:** Submission GE-0015 about "Quarkus @Scheduled concurrent execution" exists. Garden already has GE-0004 about the same topic (missed by CAPTURE light check because titles were phrased differently).

**Steps:**
1. MERGE Step 5: classifies GE-0015 as "New" initially
2. MERGE Step 5b: reads first 30 lines of GE-0004 — symptom matches
3. Presents to user: "GE-0015 looks similar to GE-0004 — duplicate?"
4. User confirms: duplicate
5. MERGE adds to DISCARDED.md: `| GE-0015 | GE-0004 | date | duplicate |`
6. MERGE adds to CHECKED.md: `| GE-0015 × GE-0004 | duplicate-discarded | date | |`
7. Submission removed from submissions/

**Expected:**
- DISCARDED.md has one entry: GE-0015 → GE-0004
- CHECKED.md has the pair logged
- GE-0015 does NOT appear in garden files or GARDEN.md index
- Submitter can check DISCARDED.md to reconcile

---

## Scenario 5: REVISE targeting by ID (happy path)

**Setup:** GE-0003 "lxml encoding detection" exists in garden. Fix found.

**Steps:**
1. Submit REVISE: `**Submission ID:** GE-0020`, `**Target ID:** GE-0003`
2. Filename: `YYYY-MM-DD-project-GE-0020-revise-lxml-encoding.md`
3. MERGE Step 4b: detects "revise" in filename and GE-0020 submission ID
4. Reads GE-0003 entry (surgical), integrates fix
5. Updates GARDEN.md index entry for GE-0003 (no new GE-ID — REVISE doesn't create a new entry)

**Expected:**
- GE-0003 entry in garden now has the fix
- GE-0020 submission removed (processed)
- GARDEN.md index for GE-0003 unchanged (same ID, updated content)
- GE-0020 noted in CHECKED.md as `GE-0020 (REVISE) → GE-0003 | integrated | date`

---

## Scenario 6: Drift threshold triggered

**Setup:** Entries merged since last sweep = 10, threshold = 10.

**Steps:**
1. User runs MERGE
2. Step 0 reads counter: 10 >= 10
3. Proposes DEDUPE sweep
4. User selects YES
5. DEDUPE runs (finds 0 issues in this scenario)
6. DEDUPE resets counter to 0, sets Last full DEDUPE sweep date
7. MERGE continues

**Expected:**
- GARDEN.md: `Entries merged since last sweep: 0`
- GARDEN.md: `Last full DEDUPE sweep: YYYY-MM-DD`
- CHECKED.md: all within-category pairs now logged
- MERGE completes normally

---

## Running the validator

```bash
cd ~/claude/knowledge-garden
python3 scripts/validate_garden.py
python3 scripts/validate_garden.py --verbose
```

Expected output after a clean merge:
```
Validating garden at /Users/mdproctor/claude/knowledge-garden

✅ Garden integrity check passed — no issues found
```
