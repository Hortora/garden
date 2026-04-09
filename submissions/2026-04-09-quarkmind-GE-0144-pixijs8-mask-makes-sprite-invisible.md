**Submission ID:** GE-0144
**Date:** 2026-04-09
**Project:** quarkmind
**Type:** gotcha
**Stack:** PixiJS 8.x

## PixiJS 8: Graphics mask added as child of anchored Sprite makes Sprite invisible

**Symptom:** A `PIXI.Sprite` with `anchor.set(0.5)` is visible in the scene graph (`visible=true`, `alpha=1`, parent container renders) but produces no pixels on the canvas. Other sprites in the same container render normally. No errors or warnings.

**Context:** Occurs when a `PIXI.Graphics` circular mask is created, added as a child of the sprite (`sprite.addChild(mask)`), then assigned as the sprite's mask (`sprite.mask = mask`). This was the documented approach in PixiJS v7.

**What was tried:** Checking `visible`, `alpha`, `renderable` — all correct. Verified texture loaded. Confirmed sprite exists in layer `children`. Canvas screenshots showed background color at sprite position.

**Root cause:** PixiJS 8 changed how child-based masks interact with anchored sprites. When the mask is a child of the masked sprite and the sprite has a non-zero anchor, the mask's local coordinate space is misaligned relative to the WebGL clipping region, causing the mask to clip away all pixels.

**Fix:** Remove the mask entirely (show rectangular sprites) or add the mask to the parent container — not the sprite — and position it in world space:

```javascript
// WRONG (PixiJS 8) — mask as child of anchored sprite
const sprite = new PIXI.Sprite(texture);
sprite.anchor.set(0.5);
const mask = new PIXI.Graphics();
mask.circle(0, 0, radius).fill(0xffffff);
sprite.addChild(mask);   // ← this breaks in PixiJS 8
sprite.mask = mask;

// FIX — no mask (rectangular sprite)
const sprite = new PIXI.Sprite(texture);
sprite.width = radius * 2;
sprite.height = radius * 2;
sprite.anchor.set(0.5);
// mask omitted — sprite renders as rectangle
```

**Why non-obvious:** The old PixiJS v7 pattern (mask as child) worked correctly. No deprecation warning, no console error. The sprite exists in the scene graph with all visibility properties correct — the only way to detect the problem is pixel sampling or `canvas.screenshot()`. Every diagnostic points to "sprite is there and visible" when it is in fact invisible.

**Suggested target:** `tools/pixijs.md` (new file: `# PixiJS Gotchas and Techniques`)

*Score: 13/15 · Included because: silent invisible-but-valid sprite, misleading diagnostics, breaking change from v7 · Reservation: PixiJS-specific*
