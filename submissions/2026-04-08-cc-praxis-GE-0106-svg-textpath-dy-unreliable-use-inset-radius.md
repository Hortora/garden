**Submission ID:** GE-0106
**Date:** 2026-04-08
**Project:** cc-praxis (Hortora blog illustration work)
**Type:** gotcha
**Stack:** SVG (all browsers, Playwright headless Chromium), any SVG textPath on a circular arc
**Suggested target:** `tools/svg.md` (new file — header: `# SVG Gotchas and Techniques`)

---

## SVG textPath `dy` attribute does not reliably position text below a circular arc line

**Symptom:** Setting `dy="14"` (or any positive value) on a `<textPath>` element referencing a circular arc path fails to move the text below the arc line. The text remains sitting on or straddling the line regardless of the `dy` value tried. No error is thrown.

**Context:** Any SVG diagram with text following the curve of a circle, where the text should sit inside the circle (below the arc line) rather than on or above it.

### What was tried (didn't work)
- `<textPath dy="14">` — text still appeared on the line
- `<textPath dy="20">` — no visible change
- `dy` on the wrapping `<text>` element instead — same result
- Increasing dy values progressively — no reliable movement

### Root cause
For a clockwise arc path going left to right across the top of a circle, SVG renders text with the baseline on the path and glyphs rising upward (away from the circle centre). The `dy` attribute shifts perpendicular to the path direction, but browser implementations vary in how they apply this offset to curved paths — the result is not reliable or consistent.

### Fix
Define the arc path at a smaller radius than the visible circle ring (inset by approximately `font-size + gap`), then use default dy=0. The text baseline sits at the inset radius, and the cap height of the glyphs rises toward (but stays inside) the ring line:

```svg
<!-- Ring circle at r=78, centre cx=420 cy=230 -->
<circle cx="420" cy="230" r="78" .../>

<!-- Text arc inset ~16px: r=62 instead of r=78 -->
<!-- Text baseline at r=62, cap height ~62+12=74 — inside the r=78 ring -->
<defs>
  <path id="arc-inner" d="M 358,230 A 62,62 0 0,1 482,230"/>
</defs>
<text font-size="12">
  <textPath href="#arc-inner" startOffset="50%" text-anchor="middle">label</textPath>
</text>
```

Inset amount ≈ font-size (12px) + gap (4px) = 16px. Adjust to taste.

### Why non-obvious
`dy` is the documented SVG attribute for shifting text perpendicular to a path. It works reliably on straight paths. On curved paths, browser rendering varies — the same `dy` value produces different results in different contexts. The inset-radius approach is nowhere documented as the preferred technique; it requires understanding that text renders above (outward from) the path by default.

*Score: 13/15 · Included because: dy unreliability only surfaces on curved paths, not straight ones; fix requires non-obvious geometry; affects any circular diagram labelling · Reservation: may vary by browser/renderer*
