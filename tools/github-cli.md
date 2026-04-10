# GitHub CLI Gotchas and Techniques

---

## Create and close GitHub issues in bulk with a bash function and URL number extraction

**ID:** GE-0049
**Stack:** GitHub CLI (`gh`), Bash
**Labels:** `#automation` `#github`
**What it achieves:** Creates and immediately closes N GitHub issues sequentially with a reusable function, capturing each issue number from the returned URL — no jq, no extra API calls, no script file.
**Context:** Retrospective issue creation, bulk issue seeding, any workflow requiring sequential issue creation where each number is needed immediately after creation.

### The technique

```bash
REPO="owner/repo"

create_and_close() {
  local title="$1" label="$2" body="$3"
  local url
  url=$(gh issue create --title "$title" --label "$label" --repo "$REPO" --body "$body" 2>&1)
  local num="${url##*/}"   # extract trailing number from https://github.com/owner/repo/issues/N
  gh issue close "$num" --repo "$REPO" --comment "Retrospectively created." >/dev/null 2>&1
  echo "$num"
}

N1=$(create_and_close "First issue title" "enhancement" "## Body\nContent here")
N2=$(create_and_close "Second issue title" "enhancement" "## Body\nContent here")
echo "Created #$N1 and #$N2"
```

`gh issue create` returns the full issue URL as its only output (e.g. `https://github.com/owner/repo/issues/42`). The `${url##*/}` bash parameter expansion strips everything up to and including the last `/`, leaving just the number.

### Why this is non-obvious

The natural approach is to parse `gh issue create --json number` or pipe through `jq`. Neither is necessary — the plain URL output already encodes the number in the final path segment, extractable with a single bash expansion. The `--json` flag is for reading issue data, not for creating issues more conveniently.

### When to use it

- Retrospective bulk issue creation (10–50 issues)
- Any sequential workflow where each issue number feeds the next step (linking parent/child, building a checklist)
- Works cleanly in a single bash session without temp files or script files

**Limitation:** The function relies on `gh issue create` returning a URL as its sole stdout. This is stable gh CLI behaviour but not documented as a contract — verify if gh CLI behaviour changes in a major version.

*Score: 11/15 · Included because: the `${url##*/}` trick is genuinely surprising; most developers would write a longer solution involving jq or a second API call · Reservation: could break if gh CLI changes its output format*

---

## `gh auth refresh` Requires an Interactive Terminal — the `!` Prefix in Claude Code Won't Complete the OAuth Flow

**ID:** GE-0113
**Stack:** GitHub CLI (`gh`), Claude Code `!` prefix, any non-interactive shell

**Symptom:** Running `! gh auth refresh -h github.com -s project,read:project` in Claude Code either returns `--hostname required when not running interactively` or appears to succeed but the new scope is never applied — subsequent `gh` calls still fail with the missing scope error.

**Context:** Any attempt to add `gh` OAuth scopes from within a Claude Code session using the `!` command prefix.

### What was tried (didn't work)
- `! gh auth refresh -s project,read:project` — returned `--hostname required when not running interactively`
- `! gh auth refresh -h github.com -s project,read:project` — appeared to run but scope was not applied; `gh auth status` still showed old scopes
- Ran it twice — same result both times

### Root cause
`gh auth refresh` completes an OAuth device flow that requires a real PTY to open a browser tab and wait for user confirmation. The `!` prefix in Claude Code runs commands in a subprocess that doesn't have an interactive terminal attached — the OAuth flow cannot complete. The command exits without error but the scope is never granted.

### Fix
Run in a real terminal window outside Claude Code:
```bash
gh auth refresh -h github.com -s project,read:project
```
Then return to the Claude Code session — the new scope is picked up immediately by subsequent `gh` calls.

### Why non-obvious
The `!` prefix appears to work for most `gh` commands. There is no error message indicating the OAuth flow was skipped — the command exits 0. The failure only surfaces when the next `gh` call requiring the new scope still fails.

*Score: 10/15 · Included because: silent failure, no indication the scope wasn't granted, affects anyone adding gh scopes mid-session · Reservation: specific to interactive OAuth flows, not all gh commands*

---

## `gh project item-edit --field-id` rejects field names — requires internal GraphQL node ID

**ID:** GE-0161
**Stack:** GitHub CLI (`gh`), GitHub Projects v2

**Symptom:**
```bash
gh project item-edit --project-id PVT_kwDO... --id PVTI_lADO... \
  --field-id "Status" --text "Done"
# → GraphQL: Could not resolve to a node with the global id of 'Status'
```

### Root cause

`--field-id` expects the internal GraphQL node ID (format: `PVTSSF_lADO...`), not the human-readable field name. The flag is named "field-id" which implies you pass the field's identifier — but GitHub Projects v2 uses opaque node IDs for all objects, and the CLI does not translate names to IDs.

### Fix

Two-step process using the GraphQL API directly:

```bash
# Step 1: get the field ID and option IDs for your project
gh api graphql -f query='{
  node(id: "PVT_kwDOEFnuXM4BT_U5") {
    ... on ProjectV2 {
      fields(first: 10) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id name options { id name }
          }
        }
      }
    }
  }
}'
# → fieldId: "PVTSSF_lADO...", optionId for "Done": "98236657"

# Step 2: update using the internal IDs
gh api graphql -f query='mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PVT_kwDO..."
    itemId: "PVTI_lADO..."
    fieldId: "PVTSSF_lADO..."
    value: { singleSelectOptionId: "98236657" }
  }) { projectV2Item { id } }
}'
```

### Why non-obvious

`gh project item-edit --help` says `--field-id string: The ID of the field to update` — "the ID of the field" reads as "the identifier you use to refer to the field", not "the GraphQL node ID". No other `gh` command requires raw GraphQL node IDs. The field name is what appears in every other part of the CLI output.

*Score: 11/15 · Included because: "field-id" strongly implies human-readable name; GraphQL node IDs are not mentioned in the help text; affects anyone automating GitHub Projects · Reservation: may be improved in future gh CLI releases*

---
