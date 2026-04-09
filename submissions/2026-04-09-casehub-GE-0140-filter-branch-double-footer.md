**Type:** gotcha
**Submission ID:** GE-0140
**Date:** 2026-04-09
**Project:** casehub
**Stack:** git (all versions)
**Scanned against:** no existing git gotchas in index

## git filter-branch --msg-filter Doubles Footers Already in Commit Bodies — Two-Pass Required

**Symptom:** After running `git filter-branch --msg-filter` to append `Refs #6` footers to historical commits, some commits have the footer twice. Also: `filter-branch` may fail immediately with "Cannot rewrite branches: You have unstaged changes" before processing any commits.

**Root cause (doubled footers):** The `--msg-filter` script is applied unconditionally to every matched commit. If some commits already contain the footer in their body (e.g. written by a subagent or earlier tool), the script appends a second copy with no awareness of the existing content.

**Root cause (unstaged changes error):** `filter-branch` refuses to run if there are any uncommitted modifications in the working tree. This includes files tracked by git that differ from HEAD — even files unrelated to the commits being rewritten.

**Fix:**

Step 1 — stash before running:
```bash
git stash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter '...' -- HEAD
git stash pop
```

Step 2 — run a second deduplication pass with inline Python:
```bash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter '
python3 -c "
import sys, re
msg = sys.stdin.read()
lines = msg.split(chr(10))
seen = set()
result = []
for line in lines:
    m = re.match(r\"^(Refs|Closes)\s+(#\d+)\", line.strip())
    if m:
        key = line.strip()
        if key not in seen:
            seen.add(key)
            result.append(line)
    else:
        result.append(line)
output = chr(10).join(result)
output = re.sub(r\"\n{3,}\", chr(10)*2, output)
sys.stdout.write(output.rstrip(chr(10)) + chr(10))
"
' -- HEAD
```

**Why non-obvious:** The filter is advertised as a message transformer — nothing in the documentation warns that it has no knowledge of existing message content. The stash requirement is documented but easy to miss because `filter-branch` is typically run in a clean repository context.

**Suggested target:** `tools/git.md`

*Score: 11/15 · Included because: non-obvious double-application behaviour, stash requirement not prominently documented, real pain when rewriting history in active repos · Reservation: moderately specific use case*
