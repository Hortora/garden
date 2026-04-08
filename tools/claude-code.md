# Claude Code Gotchas and Techniques

---

## Inject mandatory instructions directly into an existing session to override ignored guidelines

**ID:** GE-0013
**Stack:** Claude Code CLI (all versions)
**Labels:** `#claude-code` `#context` `#workflow`
**What it achieves:** Forces a live Claude session to comply with a style guide or config rule it has been ignoring, without requiring a full session handoff or restart.
**Context:** A Claude session is mid-work and productive, but has stopped honouring a style guide, CLAUDE.md rule, or loaded config — either because it drifted, or because the rule was added after the session started.

### The technique

Paste the read command and the constraint directly into the conversation as a mandatory instruction:

```
Before writing any blog content: read ~/claude-workspace/writing-styles/blog-technical.md
in full. Then complete the pre-draft classification from the AI Collaboration Voice
section — answer all three questions before generating a single sentence.
This is mandatory, not advisory.
```

The key elements:
1. **Explicit read command** — name the file and require it to be read in full, not assumed from memory
2. **Specific action before proceeding** — name the exact step Claude must complete before generating output
3. **"Mandatory, not advisory"** — signals this overrides any prior weighting; Claude cannot treat it as a suggestion to balance against its current approach

### Why this is non-obvious

The instinct when a Claude ignores a guideline is to start a new session (which auto-loads CLAUDE.md cleanly) or to update the config and do a handoff. Both interrupt productive work. The non-obvious insight: injecting the instruction directly into the live context is equivalent to what a new session's auto-load would do — it lands the content in the active window and resets Claude's behaviour immediately. No restart needed. The "mandatory, not advisory" framing is what makes it stick; a polite reminder ("please read the style guide") gives Claude room to decide the instruction is already satisfied.

### When to use it
- A session has been generating output that ignores a loaded style guide
- A rule was added to CLAUDE.md or a style guide mid-session and needs to take effect immediately
- The session is otherwise working well and a full handoff would lose valuable context
- You need a specific section of a guide to be applied, not just the whole file

**Limitation:** Only works for the remainder of the current session. A new session still needs the config in CLAUDE.md or the equivalent auto-load mechanism.

*Score: 10/15 · Included because: the mental model "new session = clean slate = correct behaviour" misses this mid-session correction path; "mandatory, not advisory" framing is the key non-obvious insight · Reservation: moderate score; workflow insight rather than technical gotcha*

---

## Large Bash tool output is saved to a temp file — `cat` on that path loops; use Read tool

**ID:** GE-0048
**Stack:** Claude Code CLI (all versions)
**Symptom:** A Bash tool call produces a large result (>~2KB). The tool result is truncated in the conversation, and the message says: `Output too large (N KB). Full output saved to: /Users/.../.claude/projects/.../tool-results/<id>.txt`. A follow-up `Bash: cat <path>` on that temp file produces the same truncation and saves to a *second* temp file. The loop can continue indefinitely.
**Context:** Any bash command whose stdout exceeds Claude Code's inline display limit — `git log`, `find`, large test output, etc.

### What was tried (didn't work)
- `Bash: cat /path/to/tool-results/<id>.txt` — triggers the same display limit; output saved to a second temp file

### Root cause
The Bash tool's display limit applies to *all* Bash tool output, including output that is itself the content of a temp file. `cat`-ing a large temp file is just another large Bash invocation. The display limit is at the tool layer, not at the command layer.

### Fix
Use the **Read tool** directly on the temp file path shown in the truncation message:

```
Read tool: /Users/.../.claude/projects/.../tool-results/<id>.txt
```

The Read tool bypasses the Bash display limit entirely — it reads files at full length (up to its own line limit, which is much larger). The content appears in full in the conversation.

### Why this is non-obvious
The natural instinct is to `cat` the temp file using another Bash call. The truncation message gives you a path and implies "read this to get the full output" — but it doesn't say *how*. Using the Read tool (a different tool, not a Bash command) is the correct approach, and the distinction isn't obvious until you've hit the loop.

*Score: 10/15 · Included because: the loop behaviour is genuinely confusing; the fix requires tool-switching which is non-obvious · Reservation: may be fixed if Claude Code raises the inline display limit*

---

## Demand-load reference material in Claude Code skills via separate .md files

**ID:** GE-0054
**Stack:** Claude Code CLI (all versions)
**Labels:** `#claude-code` `#token-budget` `#performance`
**What it achieves:** Reduces the token cost of every skill invocation by keeping heavy reference material (templates, optional workflows, modular handling) out of the SKILL.md that loads upfront, loading it only at the workflow step that needs it.
**Context:** Any Claude Code SKILL.md that contains static reference material (format templates, optional workflows, example outputs, starter templates) that is only needed at specific steps.

### The technique

Structure reference material as sibling `.md` files alongside SKILL.md. Reference them explicitly at the workflow step that needs them — not upfront:

```
skill-name/
  SKILL.md                   ← lean workflow; loads always
  reference-material.md      ← heavy content; loaded only at step N
  optional-workflow.md       ← only loaded if user triggers that path
```

In SKILL.md at the relevant step:
```markdown
### Step 5 — Write the document

Use the template in [reference-material.md](reference-material.md).
```

Claude reads the reference file when executing Step 5, not when the skill first loads. Steps 1-4 proceed without it.

Applied across 8 skills in one session: ~1,300 lines removed from hot-path SKILL.md files across the collection.

### Why this is non-obvious

Most skill authors put everything in SKILL.md for completeness. The assumption is "put it all in one place so Claude has it." But Claude Code loads the full SKILL.md upfront on every invocation regardless of which path is taken. A 600-line SKILL.md costs 600 lines every time the skill fires — even if the user only ever hits the simple path that uses 100 lines.

The reference file pattern exploits the fact that Claude reads files on demand mid-workflow. The skill can reference a file in Step 5 and Claude will read it at that point, not before.

**Extract candidates:** static content (templates, format specs, optional rarely-used workflows) that doesn't change control flow and is only needed at specific steps.

**Don't extract:** Decision logic, branching conditions, step-by-step instructions that shape how earlier steps run.

*Score: 13/15 · Included because: high-impact non-documented technique proven in practice across 8 skills in one session; ~1,300 lines removed from hot paths · Reservation: specific to Claude Code skill development context*

---

## Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers

**ID:** GE-0055
**Stack:** Claude Code CLI (all versions)
**Labels:** `#claude-code` `#token-budget` `#trigger-hygiene`
**What it achieves:** Prevents skill files from loading during sessions where they're only tangentially relevant, by keeping CSO triggers explicit (user-initiated) and having calling skills mention the skill as a pointer rather than invoking it.
**Context:** Any skill whose CSO description includes "Also triggered when [other skill] surfaces a possibility" or similar passive trigger conditions.

### The technique

**Before (bad):** `idea-log` CSO description includes:
```
Also triggered when a code review, brainstorm, or design discussion surfaces
a possibility that's not ready to act on yet.
```
Effect: idea-log (266 lines) loads during every code review session.

**After (good):** `idea-log` CSO mentions only explicit user invocation phrases.

In `code-review-principles` Step 4 (conclude):
```markdown
If an undecided possibility surfaced during the review that's not ready to act on,
mention `/idea-log` as a parking option — don't invoke it automatically.
```

The calling skill *mentions* the downstream skill as a pointer. The user reads the mention and decides whether to invoke it. The downstream skill only loads if they do.

### Why this is non-obvious

The instinct when writing skill chains is "if A often leads to B, put B in A's trigger description." This makes the chain feel tight and automatic. But for Claude Code, "in the trigger description" means "load this skill whenever those conditions match" — even when the skill ultimately does nothing.

The pointer pattern separates *awareness* (mention it in the calling skill's output) from *invocation* (only load it when the user acts on the mention). The user gets the same information; the skill load is deferred until actually needed.

**The test:** ask "does the downstream skill always execute meaningful work when triggered by this condition, or does it often find nothing and return?" If often nothing → don't auto-trigger, use a pointer mention instead.

### When to use it

- Skills that scan for patterns that are often absent (idea-log, garden in proactive mode)
- Skills whose output is "nothing found" more than 50% of the time when triggered by a condition
- Skills triggered by "when X might surface" rather than "when X has been found"

**Don't apply:** When the downstream skill always does substantive work (e.g., update-claude-md is always triggered by commit, always does something meaningful).

*Score: 12/15 · Included because: directly addresses a common over-triggering pattern; clear decision rule for when to apply · Reservation: none identified*
