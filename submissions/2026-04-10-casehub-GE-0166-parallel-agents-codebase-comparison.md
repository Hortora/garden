**Submission ID:** GE-0166
**Type:** technique
**Labels:** #strategy #architecture #agentic
**Suggested target:** tools/agentic-patterns.md or tools/claude-code.md

# Dispatch Parallel Agents for Exhaustive Cross-Codebase Comparison

## The Technique
When comparing two large codebases systematically, dispatch one agent per codebase to read every file independently, then synthesise the results. Each agent runs a full inventory: every class, interface, enum, method, and pattern. Bring the results together in the parent session for comparison.

## Why Non-Obvious
The natural approach is sequential: read system A, then read system B, then compare. This is expensive (both codebases go through the same context window) and produces shallow coverage — the agent stops when it has "enough" to answer the question. Parallel agents each have a full context budget per codebase and are explicitly tasked with leaving nothing unread.

## Example
```
Agent 1: "Read every Java file in /path/to/system-a. Inventory all classes,
          interfaces, patterns, and non-obvious capabilities."
Agent 2: "Read every Java file in /path/to/system-b. Same inventory."
Parent:  Synthesise the two inventories, produce comparison + merge plan.
```

## What This Catches
Parallel agents with explicit exhaustive briefs surface things sequential reading misses: hidden DSLs only visible in implementation files, sealed interfaces with only one permitted type, capabilities documented nowhere but the source.

## The Bar
Would a skilled developer dispatching agents naturally do this? No — the instinct is to ask one agent to "compare the two systems." That produces a surface-level comparison. The parallel exhaustive approach produces a complete one.
