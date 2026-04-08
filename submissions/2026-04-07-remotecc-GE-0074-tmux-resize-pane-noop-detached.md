**Submission ID:** GE-0074
**Date:** 2026-04-07
**Project:** remotecc
**Type:** gotcha
**Suggested target:** `tools/tmux.md` (new file — header: `# tmux Gotchas and Techniques`)

## tmux resize-pane Silently No-ops for Detached Sessions

**Stack:** tmux 3.x (all versions observed), any language spawning tmux subprocesses

**Symptom:** `tmux resize-pane -x W -y H` exits 0 with no output, but `tmux display-message -p '#{pane_width}'` still shows the original dimensions. SIGWINCH is never delivered to the process in the pane. TUI apps (Claude Code, vim) never redraw.

**Context:** Affects any program that manages tmux sessions programmatically without an attached terminal client — CI jobs, web servers, background daemons. Sessions created with `tmux new-session -d` have no attached clients by default.

**What was tried:**
- `tmux resize-pane -x 80 -y 24` — exits 0, no change
- `tmux resize-pane -x 50 -y 24` on a session created with explicit `-x 80 -y 24` — no change
- Verified the pane size with `tmux display-message -p '#{pane_width}x#{pane_height}'` — unchanged

**Root cause:** `resize-pane` is constrained by the minimum attached-client size. With no clients attached, the minimum client constraint prevents any resize. The constraint silently wins — no error is returned because the command itself succeeded (it just had no effect).

**Fix:** Use `tmux resize-window` instead:
```bash
tmux resize-window -t session-name -x 80 -y 24
```
`resize-window` bypasses the client-size constraint and reliably resizes detached sessions. For single-pane windows (the common programmatic case), the effect is identical.

**Why non-obvious:** The `tmux resize-pane` man page does not mention client-size constraints. The command exits 0, so there is no signal that it failed. A developer would need to independently verify the pane size after the call to discover the issue.

*Score: 14/15 · Included because: silent failure with no error, not documented, affects any headless tmux usage · Reservation: none*
