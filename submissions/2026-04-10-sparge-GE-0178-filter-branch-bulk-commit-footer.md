# Garden Submission

**Date:** 2026-04-10
**Submission ID:** GE-0178
**Type:** technique
**Source project:** sparge
**Session context:** Adding missing issue/epic refs to ~30 merged commits across two feature branches
**Suggested target:** `git/git-history-rewriting.md`

---

## Use `git filter-branch --msg-filter` with a Python hash→refs mapping to bulk-add commit footers

**Stack:** git (all versions), Python 3
**Labels:** `#ci-cd`, `#git`

### Problem it solves

Adding or correcting footers (e.g. `Refs #N`, `Closes #N`) on many already-committed commits. Interactive rebase becomes unwieldy past ~5 commits; this approach handles 30+ in one pass.

### Why non-obvious

Most developers reach for `git rebase -i` and manually reword each commit. The `--msg-filter` approach scales to any number of commits and is fully automatable — the script decides per-commit what to add.

### The technique

Write a Python script that reads the old message from stdin, checks `$GIT_COMMIT` against a hash→refs mapping, appends missing refs, and writes to stdout:

```python
#!/usr/bin/env python3
import sys, os

REFS = {
    'abc1234': ['Refs #42', 'Refs #43'],
    'def5678': ['Refs #41', 'Refs #40'],
    # ... one entry per commit that needs fixing
}

msg    = sys.stdin.read()
commit = os.environ.get('GIT_COMMIT', '')
to_add = next((refs for h, refs in REFS.items() if commit.startswith(h)), [])
to_add = [r for r in to_add if r not in msg]

if not to_add:
    sys.stdout.write(msg)
    sys.exit(0)

body = msg.rstrip() + '\n' + '\n'.join(to_add) + '\n'
sys.stdout.write(body)
```

Run it:
```bash
git stash   # index must be clean
FILTER_BRANCH_SQUELCH_WARNING=1 \
  git filter-branch --msg-filter 'python3 /tmp/fix_refs.py' BASE..HEAD
git stash pop
git push --force-with-lease origin BRANCH
```

### Safety net

Always create a backup tag before rewriting:
```bash
git tag backup-before-rewrite-$(date +%Y-%m-%d) HEAD
```

The tag is not force-pushed so the original history is always recoverable.
