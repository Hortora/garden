**Type:** undocumented
**Submission ID:** GE-0155
**Date:** 2026-04-09
**Project:** sparge
**Stack:** SVG, CSS Custom Properties, browser

## SVG `fill=""` presentation attributes don't reliably resolve CSS custom properties

**Symptom:** Setting `fill="var(--accent)"` on an SVG `<path>` or `<rect>` element produces no fill (or the element becomes transparent/black) instead of the token's resolved colour.

**Context:** Inline SVG in HTML where CSS custom properties are defined on the host `:root`. Works in some modern browsers with some SVG elements, but unreliable across browser versions and SVG contexts (especially when SVG is used as `<img src>` or CSS `background-image`).

**Root cause:** SVG presentation attributes (`fill=""`, `stroke=""`, etc.) are not CSS properties — they are XML attributes processed by the SVG rendering engine. CSS variable resolution (`var()`) is a CSS feature that doesn't apply to XML attribute values in all contexts. The CSS Custom Properties spec allows `var()` in CSS property values and inline `style=""` attributes, but SVG presentation attributes are a grey area with inconsistent browser support.

**What works instead:** Use the literal hex value that matches the CSS token:

```html
<!-- UNRELIABLE — may render nothing -->
<path fill="var(--accent)" d="..." />

<!-- RELIABLE — literal hex matching the token value -->
<path fill="#4a6a8a" d="..." />

<!-- Also works — inline style attribute, not presentation attribute -->
<path style="fill: var(--accent)" d="..." />
```

**Why undocumented:** The CSS Custom Properties spec doesn't explicitly address SVG presentation attributes. MDN's `var()` page doesn't mention this limitation. The distinction between "SVG presentation attribute" and "CSS property" isn't prominent in most CSS variable documentation. Developers reasonably assume that if `var()` works in `style=""` it works everywhere.

**Scanned existing entries:** GE-0106 (SVG textPath dy positioning — different issue)

*Score: 12/15 · Included because: not in var() documentation, affects anyone applying a CSS token system to inline SVG, discovered through broken styling with no error · Reservation: increasingly working in modern browsers via CSS property style="" — the presentation attribute distinction may fade*

**Suggested target:** `tools/svg.md`
