---
id: GE-20260813-quarkus-scheduled-duration-format
title: Quarkus @Scheduled rejects millisecond literals like 100ms — use 0.1s
category: gotcha
domain: quarkus
tags: [scheduler, configuration]
created: 2026-08-13
freshness: 2026-08-13
---

The `@Scheduled(every = "100ms")` annotation literal causes `DateTimeParseException` at Quarkus build time: "Invalid every() expression". Use `"0.1s"` instead. Note: the `${config-property:default}` form (e.g., `"${fsi.market.tick-interval:500ms}"`) works fine because Quarkus config handles the parsing separately from the annotation literal parser. The distinction: annotation literals go through `Duration.parse()` directly; config values go through Quarkus's own converter which accepts more formats.
