---
id: PP-20260531-ef4da8
title: "General-purpose SingleValuePreference implementations belong in domain.preferences"
type: rule
scope: application
applies_to: "casehub-devtown domain module — any new SingleValuePreference subtype"
severity: guidance
refs:
  - devtown#59
violation_hint: "A new preference type (e.g. FloatPreference, BooleanPreference) added to domain.trust or domain.sla rather than domain.preferences"
created: 2026-05-31
---

`io.casehub.devtown.domain.preferences` is the home for `SingleValuePreference` implementations that have no coupling to a specific domain concept. `DoublePreference` and `IntPreference` were initially placed in `domain.trust` and `domain.sla` respectively — both wrong, as these types are reusable across any domain concern. Any future preference type (e.g. `BooleanPreference`, `LongPreference`) that holds a scalar value without domain semantics belongs in `domain.preferences`, not in a domain-specific sub-package.
