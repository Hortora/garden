---
id: GE-20260813-topic-registry-colon-separator
title: Pages-push TopicRegistry uses colon as segment separator, not slash
category: undocumented
domain: casehub-pages
tags: [push, websocket, topic]
created: 2026-08-13
freshness: 2026-08-13
---

`TopicRegistry` in `casehub-pages-push` splits topic strings on `:` (colon), not `/` (slash). Topics should be formatted as `market:ticks:AAPL`, not `market/ticks/AAPL`. Wildcard patterns use `*` (single segment) and `**` (trailing multi-segment), also colon-delimited: `market:ticks:*` or `market:**`. This is not documented anywhere — discovered by reading `TopicRegistry.java` source.
