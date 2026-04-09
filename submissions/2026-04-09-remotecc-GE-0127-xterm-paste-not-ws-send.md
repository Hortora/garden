**Type:** technique
**Submission ID:** GE-0127
**Date:** 2026-04-09
**Project:** remotecc
**Stack:** xterm.js 5.x, @xterm/addon-attach
**Labels:** #pattern, #testing
**Suggested target:** `tools/xterm.md` (new file — `# xterm.js Gotchas and Techniques`)

---

## Use terminal.paste() not ws.send() to inject text into an xterm.js terminal from JavaScript

**What it achieves:** Reliably sends text through the xterm.js AttachAddon input pipeline, including correct bracketed paste mode handling, without depending on a direct WebSocket reference that may be stale after reconnects.

**The problem:** When using `@xterm/addon-attach`, the natural approach to inject text from JavaScript is to call `ws.send(text)` directly on the WebSocket — the same socket the AttachAddon uses. This works initially but breaks in two ways: (1) if the WebSocket reconnects, the AttachAddon disposes and recreates its binding, but your `ws` reference may still point to the old socket; (2) `ws.send()` bypasses bracketed paste mode (`\x1b[200~...\x1b[201~`), which terminal applications like Claude Code's Ink input enable and rely on for correct multi-character paste behaviour.

**The technique:**

```javascript
// WRONG — bypasses AttachAddon, breaks on reconnect, no bracketed paste
ws.send(text);

// RIGHT — routes through AttachAddon's onData handler, handles bracketed paste
terminal.paste(text);
```

`terminal.paste(data)` fires the xterm.js `onData` event. AttachAddon listens to `onData` and forwards it to the WebSocket. This path is always current regardless of reconnects. xterm.js automatically wraps the text in `\x1b[200~...\x1b[201~` if the connected application has enabled bracketed paste mode.

**Why non-obvious:** `ws.send()` works correctly for single keystrokes (as the key bar does), making it seem like the right approach for longer text too. The failure mode is subtle: `ws.send()` succeeds without error but the text either doesn't arrive or arrives incorrectly. `terminal.paste()` is documented in the xterm.js API but its role as the correct input injection method for addon-based setups is not explained.

*Score: 13/15 · Included because: took five failed iterations to discover, the correct method is not obvious from the API docs, applies to any xterm.js + AttachAddon setup · Reservation: none*
