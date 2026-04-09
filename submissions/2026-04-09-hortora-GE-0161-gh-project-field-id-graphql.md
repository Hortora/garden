---
title: "gh project item-edit --field-id rejects field names — requires internal GraphQL node ID"
type: gotcha
domain: tools/github-cli
score: 11
tags: [github-cli, github-projects, graphql, gh]
verified: 2026-04-09
staleness_threshold: 180
summary: "gh project item-edit --field-id 'Status' fails with a GraphQL error — the flag requires the internal PVTSSF_... node ID, not the human-readable field name."
---

**Submission ID:** GE-0161
**Suggested target:** `tools/github-cli.md`

## Symptom

```bash
gh project item-edit --project-id PVT_kwDO... --id PVTI_lADO... \
  --field-id "Status" --text "Done"
# → GraphQL: Could not resolve to a node with the global id of 'Status'
```

## Root Cause

`--field-id` expects the internal GraphQL node ID (format: `PVTSSF_lADO...`), not the human-readable field name. The flag is named "field-id" which implies you pass the field's identifier — but GitHub Projects v2 uses opaque node IDs for all objects, and the CLI does not translate names to IDs.

## Fix

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

## Why Non-Obvious

`gh project item-edit --help` says `--field-id string: The ID of the field to update` — "the ID of the field" reads as "the identifier you use to refer to the field", not "the GraphQL node ID". No other gh command requires raw GraphQL node IDs. The field name is what appears in every other part of the CLI output.
