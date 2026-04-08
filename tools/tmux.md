# tmux Gotchas and Techniques

Discovered building headless JVM systems that interact with tmux, and writing tests that use tmux as a terminal bridge.

---

## send-keys silently interprets "Enter"/"Escape" as key names without -l flag

**ID:** GE-0096
**Stack:** tmux 3.x; `-l` literal flag requires 3.2+
**Symptom:** `tmux send-keys -t session "Escape"` fires the actual Escape key instead of typing the word "Escape". `"Enter"` sends a newline instead of the text. No error, no warning. User input containing key names fires those keys silently.
**Context:** Any code that sends user-provided text to tmux — terminal emulators, test harnesses, remote CLI tools.

### What was tried (didn't work)
- Sending text directly without -l — key names are silently interpreted

### Root cause
tmux `send-keys` processes each argument as a key specification. Single characters are sent as typed. But strings that exactly match a name in tmux's key table (Enter, Escape, Tab, Up, F1, etc.) fire the corresponding key instead of typing the text.

### Fix
Always use `-l` (literal) flag:
```bash
# ❌ "Escape" fires Escape key, "Enter" sends newline
tmux send-keys -t session "Escape"

# ✅ sends the literal text
tmux send-keys -t session -l "Escape"
tmux send-keys -t session -l "Enter"
```

In Java:
```java
new ProcessBuilder("tmux", "send-keys", "-t", sessionName, "-l", userText)
    .start().waitFor();
```

### Why this is non-obvious
The tmux man page documents this but the distinction is easy to miss. Text containing "Enter" or "Escape" as words looks fine in casual testing (most text doesn't contain exact key names) but breaks unpredictably with real user input. The bug manifests silently — wrong keystrokes sent, no error.

---

## send-keys key name lookup is per-argument, not per-word within an argument

**ID:** GE-0097
**Stack:** tmux 3.x
**Symptom:** A test designed to verify the `-l` fix passes even without `-l` when the test text is `"echo Escape marker"`. The bug is real but the test doesn't catch it.
**Context:** Writing a test to prove the send-keys -l bug exists. The granularity of key-name matching matters for test design.

### What was tried (didn't work)
- Sent `"echo Escape marker"` as a single argument without `-l` — bug doesn't manifest; all characters sent literally because the whole string isn't a key name
- Sent `"echo Escape marker\n"` — same result; the bug only fires when the entire argument exactly matches a key name

### Root cause
tmux checks whether the *entire argument* matches a key name, not whether a key name appears as a substring. `"echo Escape marker"` as a single argument does not match any key name, so all characters are sent literally — even without `-l`. Only when the argument is exactly `"Escape"` does tmux fire the Escape key.

### Fix for test design
To expose the bug, send the key name as the complete argument:
```java
// WRONG — bug doesn't manifest (whole string isn't a key name)
tmux.sendKeys(session, "echo Escape marker");

// CORRECT — bug manifests (argument IS a key name)
tmux.sendKeys(session, "Escape");
```

The fix (always use `-l`) remains correct and important. This entry clarifies how to write a test that actually demonstrates the bug.

### Why this is non-obvious
Most developers write `"echo Escape marker"` to test the bug (natural, readable), are confused when the test passes without the fix, and conclude the bug doesn't exist. The per-argument granularity is not documented.

---

## capture-pane pads every output line to full pane width — blank lines are grid artifacts

**ID:** GE-0098
**Stack:** tmux 3.x
**Symptom:** Terminal replay sends cursor to column 80+ after each line. Blank lines in `capture-pane -p` output are not empty — they are space-padded to the pane width.
**Context:** Any code that captures tmux pane content and replays it to a terminal emulator (xterm.js, VT100 parser, etc.).

### Root cause
`tmux capture-pane -p` pads every line to the full pane width with spaces. A "blank" line is actually 220 spaces (or whatever the pane width is). When replayed to a terminal, these spaces move the cursor to column 220, then the next character jumps to the next row at a non-zero column.

### Fix
Two-pass approach for clean replay:
```bash
# Step 1: capture with ANSI codes preserved
tmux capture-pane -t session -e -p -S -100 > /tmp/raw.txt

# Step 2: strip trailing spaces and purely-blank lines
sed 's/[[:space:]]*$//' /tmp/raw.txt | sed '/^$/d'
```

Or in a pipeline:
```java
// After capture-pane, strip trailing whitespace per line before sending to terminal
String cleaned = Arrays.stream(rawOutput.split("\n"))
    .map(line -> line.stripTrailing())
    .collect(Collectors.joining("\n"));
```

### Why this is non-obvious
The output looks correct when printed to a standard terminal (terminals handle trailing spaces gracefully). The problem only surfaces when the output is fed to a terminal emulator that tracks cursor position precisely — the trailing spaces move the cursor, causing misalignment on the next write.

---

## attach-session fails from ProcessBuilder — requires a real PTY

**ID:** GE-0099
**Stack:** tmux 3.x, Java ProcessBuilder (any JVM version)
**Symptom:** `tmux attach-session` from a Java ProcessBuilder exits immediately with "not a terminal" or similar. The session exists and tmux is running fine.
**Context:** Any headless JVM, daemon, or server process trying to attach to a tmux session.

### Root cause
`tmux attach-session` calls `isatty()` on its stdin/stdout and refuses to run if they are not a real PTY. Java's `ProcessBuilder` provides pipes, not PTYs. There is no way to make `attach-session` work from a headless process.

### Fix
Use `pipe-pane` with a named FIFO instead — no PTY required:

```java
var fifoPath = "/tmp/my-session-" + connectionId + ".pipe";

// 1. Create the FIFO
new ProcessBuilder("mkfifo", fifoPath).start().waitFor();

// 2. Start reader FIRST (blocks until writer connects — correct, not a deadlock)
Thread.ofVirtual().start(() -> {
    try (var in = new BufferedInputStream(new FileInputStream(fifoPath))) {
        var buf = new byte[4096];
        int n;
        while ((n = in.read(buf)) != -1) {
            // process chunk — send to WebSocket, write to log, etc.
        }
    }
});

// 3. Start pipe-pane (cat connects to FIFO, unblocks the reader)
new ProcessBuilder("tmux", "pipe-pane", "-t", sessionName, "cat > " + fifoPath)
    .start().waitFor();

// Cleanup (on session end):
// new ProcessBuilder("tmux", "pipe-pane", "-t", sessionName).start();  // no command = stop
// Files.deleteIfExists(Path.of(fifoPath));
```

**Key ordering:** Start the FIFO reader thread BEFORE pipe-pane. Opening a FIFO blocks until both sides are ready — reader blocks until cat connects, cat blocks until reader opens. Starting pipe-pane first risks a race.

### Why this is non-obvious
`attach-session` is the obvious way to "connect to" a tmux session. The PTY requirement is documented but easy to miss until you hit it. The FIFO + pipe-pane approach is not in the standard tmux documentation and requires understanding FIFO semantics.

*The fix above is also a reusable technique — Labels: `#pattern` `#headless-jvm` `#streaming`*

---

## TUI apps render garbled on WebSocket connect — tmux pane dimensions not synced to browser viewport

**ID:** GE-0100
**Stack:** tmux 3.x, WebSocket, xterm.js (any browser terminal emulator)
**Symptom:** TUI apps (vim, claude, ncurses programs) render garbled or wrong-width when a WebSocket client connects to a tmux session streamed via pipe-pane. Lines wrap incorrectly, screens are truncated, or the whole layout is off. Manual browser window resize fixes it immediately.
**Context:** Any server streaming tmux pane output to a browser via WebSocket + xterm.js, where the tmux pane may have different dimensions than the browser terminal viewport.

### What was tried (didn't work)
- Accepted "terminal resize triggers correct redraw" as a known workaround — the garbling persisted for the entire development period before the root cause was identified
- The issue was assumed to be a history-replay ordering problem (history sent at the wrong moment) — was not

### Root cause
tmux pane dimensions are independent state. The pane may be 220 cols wide from a previous session while xterm.js is rendering at 80×24. TUI apps calculate their layout based on SIGWINCH from tmux. If the pane dimensions don't match the browser viewport at the moment the stream begins, the TUI draws at the wrong width — wrap points are wrong, cursor positions are wrong, and the whole screen is garbled. The pane dimensions only update when something explicitly sends SIGWINCH with new values via `resize-pane`.

### Fix
Pass the browser terminal dimensions in the WebSocket URL path, and call `tmux resize-pane` with those dimensions **before** starting `pipe-pane`. The resize delivers SIGWINCH, the TUI redraws at the correct size, and the live stream starts clean.

Frontend (pass dimensions at connect time):
```javascript
function connect() {
    var wsUrl = proto + '//' + location.host + '/ws/' + sessionId
        + '/' + terminal.cols + '/' + terminal.rows;
    ws = new WebSocket(wsUrl);
    // ...
}
```

Backend (`@OnOpen` handler, before pipe-pane):
```java
int cols = parsePathInt(connection.pathParam("cols"));
int rows = parsePathInt(connection.pathParam("rows"));
if (cols > 0 && rows > 0) {
    new ProcessBuilder("tmux", "resize-pane", "-t", tmuxName,
            "-x", String.valueOf(cols), "-y", String.valueOf(rows))
            .redirectErrorStream(true).start().waitFor();
}
// Now: history replay, then pipe-pane — TUI has already redrawn at correct size
```

The WebSocket path becomes `/ws/{sessionId}/{cols}/{rows}`. Use `0/0` in tests that don't care about sizing.

**Python/FastAPI alternative** (same logic, different stack):

```python
# WebSocket URL format — client embeds its dimensions
/ws/{session_id}/{cols}/{rows}

@app.websocket("/ws/{session_id}/{cols}/{rows}")
async def websocket_endpoint(websocket: WebSocket, session_id: str, cols: int, rows: int):
    await websocket.accept()

    # 1. Send existing history first
    history = get_session_history(session_id)
    if history:
        await websocket.send_text(history)

    # 2. Resize pane to match client — delivers SIGWINCH to TUI
    subprocess.run(
        ["tmux", "resize-pane", "-t", session_id, "-x", str(cols), "-y", str(rows)],
        check=True
    )

    # 3. Start live stream — TUI has already redrawn into the live output
    await start_pipe_pane(session_id, websocket)
```

**Critical ordering:** resize happens **after** history is sent but **before** `pipe-pane` starts. This means the TUI's redraw response goes into the live stream, not the history buffer — so the first thing the client sees in the live stream is clean TUI state. Resize the pane first (before sending history), and the redraw goes into the history buffer where it creates stale artifacts. Resize after pipe-pane starts, and the client briefly sees garbled state before the redraw arrives.

### Why this is non-obvious
Garbled TUI rendering looks like a replay ordering problem (history sent at the wrong time), an ANSI escape stripping issue, or an xterm.js parser bug. Nothing in the error output points to pane dimensions. You have to know that tmux tracks pane size as independent state, that SIGWINCH is what causes TUI redraws, and that the fix must happen before `pipe-pane` starts (resize after the stream begins means the garbled initial state is already visible). Also non-obvious: dimensions must go in the URL path — WebSocket headers are not accessible from `@OnOpen` path params in Quarkus WebSockets Next.

*[GE-0014 — solution revision — Score: 14/15 · Transforms "here's the problem" into complete solution; the history→resize→pipe-pane ordering is the non-obvious part]*

---

## tmux resize-pane Silently No-ops for Detached Sessions

**ID:** GE-0074
**Stack:** tmux 3.x (all versions observed)
**Symptom:** `tmux resize-pane -x W -y H` exits 0 with no output, but `tmux display-message -p '#{pane_width}'` still shows the original dimensions. SIGWINCH is never delivered to the process in the pane. TUI apps never redraw.
**Context:** Any program that manages tmux sessions programmatically without an attached terminal client — CI jobs, web servers, background daemons. Sessions created with `tmux new-session -d` have no attached clients by default.

### What was tried (didn't work)
- `tmux resize-pane -x 80 -y 24` — exits 0, no change
- `tmux resize-pane -x 50 -y 24` on a session created with explicit `-x 80 -y 24` — no change
- Verified the pane size with `tmux display-message -p '#{pane_width}x#{pane_height}'` — unchanged

### Root cause
`resize-pane` is constrained by the minimum attached-client size. With no clients attached, the minimum client constraint prevents any resize. The constraint silently wins — no error is returned because the command itself succeeded (it just had no effect).

### Fix
Use `tmux resize-window` instead:
```bash
tmux resize-window -t session-name -x 80 -y 24
```
`resize-window` bypasses the client-size constraint and reliably resizes detached sessions. For single-pane windows (the common programmatic case), the effect is identical.

### Why this is non-obvious
The `tmux resize-pane` man page does not mention client-size constraints. The command exits 0, so there is no signal that it failed. A developer would need to independently verify the pane size after the call to discover the issue.

*Score: 14/15 · Included because: silent failure with no error, not documented, affects any headless tmux usage · Reservation: none*

---

## tmux capture-pane Output Ends with \n — split() Gives paneHeight+1 Elements

**ID:** GE-0075
**Stack:** tmux 3.x, any language that splits capture-pane output by newline
**Symptom:** Row arithmetic using `lines.length - paneHeight + cursorY` gives the wrong row by exactly 1. A cursor positioning escape lands one row below the intended target.
**Context:** When using `tmux capture-pane -p -S -N` output and splitting on `\n` with a negative limit, the captured output always ends with `\n`, producing one extra empty string at the end of the array.

### What was tried (didn't work)
- Calculating `paneRowInCapture = lines.length - paneHeight + paneCursorY` — off by 1
- Logging `lines.length` vs `paneHeight` — differed by exactly 1

### Root cause
`tmux capture-pane -p` output is `row1\nrow2\n...rowN\n` — a trailing newline after every row including the last. When split by `\n` with an empty-trailing-element mode, this yields `N+1` elements where the last is `""`.

### Fix
```java
// Java
int captureSize = lines[lines.length - 1].isEmpty()
    ? lines.length - 1 : lines.length;
int paneRowInCapture = (captureSize - paneHeight) + paneCursorY;
```
```python
# Python
lines = raw.split('\n')
if lines and lines[-1] == '':
    lines = lines[:-1]
capture_size = len(lines)
```

### Why this is non-obvious
The trailing newline is invisible in log output. `len(lines)` looks correct at a glance. The off-by-one only manifests as a visual cursor position error, which is easy to attribute to other causes (wrong pane height, wrong cursor reading, etc.).

*Score: 12/15 · Included because: silent arithmetic error with misleading symptom, stable tmux behaviour · Reservation: slightly language-specific in the fix, but root cause is universal*
