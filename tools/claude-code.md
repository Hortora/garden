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

---

## validate_document.py flags markdown tables inside fenced code blocks as corrupted

**ID:** GE-0091
**Stack:** cc-praxis skills repo, validate_document.py (Python), any type:skills project
**Symptom:** Running `python3 scripts/validate_document.py <file>.md` returns:
```
❌ CRITICAL issues found:
  - Corrupted table at line N: Table header followed by prose instead of data row
```
The flagged line is a valid markdown table row inside a fenced code block. The table itself is well-formed; the error is a false positive.
**Context:** Any markdown document containing a markdown table as an example inside a fenced code block. Common in design documents, documentation specs, and files showing the format of INDEX.md or similar.

### Root cause
`validate_document.py` does not correctly track code-fence state. It parses markdown tables inside fenced blocks as if they were real markdown tables in the document body. When the last table row appears immediately before the closing fence marker, the validator sees the fence as "prose instead of a data row" following the table, triggering the CRITICAL error.

### Fix
Add a blank line before the closing fence to break the validator's false pattern match:

```markdown
| col1 | col2 |
|------|------|
| val  | val  |

` `` `
```

This prevents the closing fence from being parsed as "prose after a table row."

The real fix is to update validate_document.py to track code-fence state and skip table validation for content inside fenced blocks.

### Why non-obvious
The error message points to a specific line number with content that looks like a valid table row. Nothing in the error message indicates the issue is the code fence context rather than the table itself. Developers will inspect the table columns repeatedly before realising the fenced block is the problem. The workaround (blank line) is counterintuitive — you're adding "wrong" whitespace to fix a validator bug.

*Score: 11/15 · Included because: blocks commits via pre-commit hook; symptom completely misleads about root cause; blank-line workaround is non-obvious · Reservation: specific to validate_document.py in cc-praxis*

---

## `mv` Project Folder Invalidates Bash Tool's Shell cwd Mid-Session

**ID:** GE-0121
**Stack:** Claude Code Bash tool, macOS shell

**Symptom:** After renaming a project folder with `mv /old /new`, all subsequent Bash tool calls fail with "Working directory '/old' no longer exists. Please restart Claude from an existing directory." even when using absolute paths in the command. The shell is completely unusable for the remainder of the session.

**Context:** Any Claude Code session where a project folder is renamed using `mv` — or any shell command that moves the directory that was the working directory when the shell process started.

### Root cause
The Bash tool's shell process was started with cwd set to the old folder path. When the folder is renamed, the shell's cwd inode becomes invalid. The shell process cannot recover — it fails on startup for each subsequent call. The error message suggests restarting Claude rather than pointing to the folder rename as the cause.

Compounding this: the `Read`, `Write`, `Edit`, and `Glob` tools do NOT use the shell's cwd and continue to work after the rename, since they use the absolute paths passed to them directly. This makes the failure seem inconsistent and puzzling.

### Fix
Three mitigations:
1. **Do the rename last** — if you know a folder rename is needed, make it the absolute final operation in the session after all other work is complete.
2. **Use non-shell tools after the rename** — `Read`, `Write`, `Edit` work via absolute path and are unaffected. For file content operations, they can substitute for many bash commands.
3. **Use the IntelliJ MCP `execute_terminal_command` tool** if available — this spawns a fresh process with its own working directory and bypasses the broken shell state.

For a new agentic session, start from an existing directory (e.g., the renamed path) and the shell initialises correctly.

### Why non-obvious
`mv` succeeds silently (exit 0), so there is no error at rename time. The failure only appears on the next unrelated bash command, with an error message that suggests restarting Claude rather than pointing to the rename as the cause. Developers will try re-running the failed command with explicit absolute paths (which should work) and be confused when it still fails — because the problem is not the command, it is the shell process itself.

*Score: 11/15 · Included because: non-obvious symptom that blames Claude restart rather than the rename; affects the whole session; cross-project whenever a folder is renamed mid-session · Reservation: only hits when you rename a folder in an agentic session, which is uncommon — but painful when it does*

---

## Renaming a Claude Code Project Directory Leaves Stale Absolute Paths in `.claude/settings.local.json`

**ID:** GE-0124
**Stack:** Claude Code (any version), macOS/Linux

**Symptom:** After renaming a project directory (e.g. `mv ~/claude/skills ~/claude/cc-praxis`), previously granted permissions silently fail or behave unexpectedly. A ghost directory (`~/claude/oldname/.claude/`) may also appear containing a near-duplicate of the original `settings.local.json`.

**Context:** Any Claude Code project that accumulates granted permissions over time and is later renamed or moved.

### What was tried (didn't work)
- `mv ~/claude/skills ~/claude/cc-praxis` — the directory renamed correctly but permissions referencing the old absolute path remained broken
- Assuming `mv` would handle everything — it moves bytes but not content strings

### Root cause
`settings.local.json` accumulates absolute path permission entries over time (every `Bash(...)`, `Read(...)` etc. approval gets recorded). `mv` renames the directory but does not update the string contents of files. All permissions containing the old path silently no longer match the new location. Additionally, a ghost `~/claude/oldname/.claude/` directory can appear after the rename — likely recreated by Claude Code or a session-start hook attempting to access the old path.

### Fix
After renaming, update all path references in the new location's `settings.local.json`:

```bash
sed -i '' 's|/Users/me/claude/skills/|/Users/me/claude/cc-praxis/|g' \
  ~/claude/cc-praxis/.claude/settings.local.json

# Verify no old paths remain
grep "claude/skills/" ~/claude/cc-praxis/.claude/settings.local.json
```

Then remove the ghost directory if it appeared:
```bash
rm -rf ~/claude/oldname/
```

### Why non-obvious
`mv` is a well-understood command — developers assume it handles a rename completely. Nothing warns you that file *contents* still reference old paths. Permissions fail silently (the tool just isn't granted rather than throwing an error), making it hard to connect the symptom to the rename. The ghost directory appearing post-rename adds confusion about whether the rename succeeded at all.

**See also:** GE-0121 (mv also invalidates the Bash tool's shell cwd mid-session)

*Score: 12/15 · Included because: silent failure, cross-project (any Claude Code rename), fix requires knowing to look inside settings.local.json · Reservation: somewhat specific to Claude Code's permission accumulation model*

---

## macOS tmp filesystem full silently blocks all Claude Code Bash tool commands

**ID:** GE-0157
**Stack:** Claude Code (macOS), Bash tool

**Symptom:** Every Bash tool invocation fails with `ENOSPC: no space left on device, open '/private/tmp/claude-501/...'`, regardless of what the command actually does. Commands that don't write files at all (e.g. `git log`, `echo done`) also fail. The error message names a temp path, not any project directory. The actual command may or may not have executed — there is no way to tell from the error.

**Context:** Claude Code writes each Bash tool call's output to a temp file under `/private/tmp/claude-501/<session-path>/tasks/`. When this directory fills up, the tool cannot write output and fails before reporting the command result.

### What was tried

Assumed disk space was genuinely exhausted. Tried shorter commands, different paths. All failed identically. Checked project directories — all had space. The temp path in the error message was the clue.

### Root cause

The temp directory used by the Claude Code Bash tool output buffer is separate from the system's general temp space and can fill independently — particularly after a long session with many large-output commands (e.g. Maven builds with verbose output).

### Fix

```bash
rm -rf /private/tmp/claude-501/
```

After clearing, all Bash tool commands resume normally. The session continues without restart.

### Why non-obvious

The error message looks like a general filesystem problem. `df -h` on the project volume shows plenty of space. Nothing in Claude Code UI indicates the issue. The fix directory (`/private/tmp/claude-501/`) is non-obvious and not documented anywhere.

**See also:** GE-0160 (parallel subagents specifically fill this temp dir — prevention strategy)

*Score: 13/15 · Included because: completely opaque failure, standard disk checks don't find it, non-obvious fix location · Reservation: macOS-specific*

---

## Gitignored CLAUDE.md symlink for consistent AI workspace config across entry points

**ID:** GE-0159
**Stack:** Claude Code, git (any version), any project
**Labels:** `#workflow` `#claude-code`

**The problem:** When designing a workspace model where Claude should always open in a dedicated workspace directory, IDE integrations and developer muscle memory keep opening Claude in the project directory instead. If the workspace CLAUDE.md isn't loaded, skills route incorrectly, artifact paths are wrong, and session context is lost.

**The technique:** Create a gitignored symlink at the project root pointing to the workspace CLAUDE.md:

```bash
# Create symlink: project's CLAUDE.md → workspace CLAUDE.md
ln -sf ~/claude/private/<project>/CLAUDE.md /path/to/project/CLAUDE.md

# Hide it from git WITHOUT touching tracked .gitignore
# (works for upstream repos you don't own — Drools, any open source project)
echo "CLAUDE.md" >> /path/to/project/.git/info/exclude
```

Claude Code follows project-level symlinks and reads the workspace CLAUDE.md regardless of where it opens. Opening in the project by mistake still loads the correct config — workspace paths, session-start instructions, skill routing table.

**Why `.git/info/exclude`, not `.gitignore`:**
`.gitignore` is a tracked file — modifying it creates a diff, and for projects you don't own you have no right to commit it. `.git/info/exclude` is local-only, never committed, never shared. It works identically but is invisible to other contributors. Use it consistently for all projects regardless of ownership.

**Why non-obvious:**
- Most developers know `.git/info/exclude` exists but rarely use it
- The symlink-to-config pattern is unusual; people typically copy config files or use environment variables
- The combination (symlink + local exclude) makes the project completely clean to other contributors while Claude gets the right config from either entry point

*Score: 14/15 · Non-obvious approach combining two underused git mechanisms to solve a real workspace config problem*

---
