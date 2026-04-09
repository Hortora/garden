**Submission ID:** GE-0150
**Date:** 2026-04-09
**Project:** quarkmind
**Type:** technique
**Stack:** Playwright Java 1.49.0, PixiJS 8, any canvas-based frontend
**Labels:** #testing #strategy

## Expose `window.__test` semantic API for robust canvas/WebGL test assertions

**Technique:** Instead of pixel-comparison screenshots (fragile) or DOM selectors (unavailable on `<canvas>`), expose a `window.__test` object from the JavaScript app with helpers that return serialisable state. Playwright's `page.evaluate()` calls these helpers for semantic assertions that survive visual style changes while catching behavioral regressions.

**What developers normally do:** Take screenshots and compare pixels, or accept that canvas-rendered UIs are untestable without visual regression tools. Both approaches are fragile — pixel comparison breaks on any visual change, and skipping tests leaves the rendering unverified.

**The approach:**

In the JS app (e.g. PixiJS `init()`), expose test hooks before loading assets:

```javascript
// In visualizer.js — set before loadAssets() so tests don't wait for network
window.__pixiApp = app;
window.__test = {
    spriteCount:  (prefix) =>
        [...activeSprites.keys()].filter(k => k.startsWith(prefix + ':')).length,
    sprite:       (key) => {
        const s = activeSprites.get(key);
        if (!s) return null;
        return { x: s.x, y: s.y, alpha: s.alpha ?? 1,
                 visible: s.visible !== false, hasMask: s.mask != null };
    },
    hudText:      () => hudText?.text ?? '',
    assetLoaded:  (alias) => PIXI.Assets.get(alias) !== undefined,
    wsConnected:  () => wsConnected,
};
```

In Playwright Java tests:

```java
// Semantic count assertion — survives layout changes
long units = ((Number) page.evaluate(
    "() => window.__test.spriteCount('unit')")).intValue();
assertThat(units).isEqualTo(12);

// Position derived from game coordinates — never hardcoded
Map<?,?> nexus = (Map<?,?>) page.evaluate(
    "() => window.__test.sprite('building:nexus-0')");
assertThat(((Number) nexus.get("x")).intValue()).isEqualTo(tileX(8)); // 160

// Mask regression test — catches PixiJS 8 invisible-sprite bug
boolean noMasks = (boolean) page.evaluate(
    "() => Array.from({length:12}, (_,i) => window.__test.sprite('unit:probe-'+i))" +
    "      .every(s => s !== null && !s.hasMask)");
assertThat(noMasks).isTrue();
```

**Why non-obvious:** Most developers either skip canvas testing or reach for visual regression tools (Percy, Applitools, screenshot diffs). The `window.__test` pattern bridges the gap: it's deterministic, fast, and catches behavioral regressions without being coupled to visual style. Positions derived from game coordinate math are stable across layout changes; only the game logic breaking can fail them.

**Suggested target:** `tools/playwright.md`

*Score: 13/15 · Included because: solves a widely-avoided problem (canvas testing), non-obvious to combine page.evaluate with app-side test hooks, concrete alternative to fragile screenshot comparison · Reservation: requires modifying the app under test*
