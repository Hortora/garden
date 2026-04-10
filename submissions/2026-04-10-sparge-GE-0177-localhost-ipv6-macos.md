# Garden Submission

**Date:** 2026-04-10
**Submission ID:** GE-0177
**Type:** gotcha
**Source project:** sparge
**Session context:** Electron health-check polling http://127.0.0.1:PORT/api/config while Python server binds to localhost
**Suggested target:** `python/http-server.md`

---

## Python `HTTPServer('localhost', port)` may bind to IPv6 on macOS 14+ — health checks on 127.0.0.1 then fail

**Stack:** Python 3.12, macOS 14 (Sonoma)+
**Symptom:** Health-check polling `http://127.0.0.1:PORT/...` times out or ECONNREFUSED, even though the server appears to be running. No error from the server itself.
**Context:** Using `http.server.HTTPServer(('localhost', port), Handler)` while polling the server via `127.0.0.1`.

### What was tried (didn't work)

- Starting `HTTPServer(('localhost', port), ...)` — server starts without error
- Polling `http://127.0.0.1:port/api/config` — ECONNREFUSED or timeout

### Root cause

On macOS 14+, `localhost` resolves to `::1` (IPv6 loopback) in some configurations. `HTTPServer` binds to `::1`, while `http.get('http://127.0.0.1:...')` is an IPv4 connection — a different network interface. The server is listening but not on the IPv4 loopback.

This is a known macOS Sonoma behaviour where IPv6 takes precedence for `localhost` resolution.

### Fix

Bind explicitly to `127.0.0.1`:

```python
HTTPServer(('127.0.0.1', args.port), Handler).serve_forever()
```

Both server and client then use IPv4. Avoids the dual-stack ambiguity entirely.
