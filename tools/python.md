# Python Gotchas

## Python `HTTPServer('localhost', port)` may bind to IPv6 on macOS 14+ — health checks on 127.0.0.1 then fail

**ID:** GE-0177
**Stack:** Python 3.12, macOS 14 (Sonoma)+
**Symptom:** Health-check polling `http://127.0.0.1:PORT/...` times out or gets ECONNREFUSED, even though the server appears to be running. No error from the server itself.
**Context:** Using `http.server.HTTPServer(('localhost', port), Handler)` while the health-check client connects via `127.0.0.1`.

**Root cause:** On macOS 14+, `localhost` resolves to `::1` (IPv6 loopback) in some configurations. `HTTPServer` binds to `::1`, while `http.get('http://127.0.0.1:...')` is an IPv4 connection — a different interface. The server is listening but not on IPv4 loopback.

**Fix:** Bind explicitly to `127.0.0.1`:
```python
HTTPServer(('127.0.0.1', args.port), Handler).serve_forever()
```
Both server and client then use IPv4. Avoids dual-stack ambiguity entirely.

*Score: 12/15 · Highly non-obvious — server starts without error, client gets ECONNREFUSED with no indication of interface mismatch; macOS 14 behaviour change makes previously working code fail silently · Reservation: macOS Sonoma-specific*

---
