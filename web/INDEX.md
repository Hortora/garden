| GE-ID | Title | Type | Score |
|-------|-------|------|-------|
| GE-20260420-060bd6 | escapeHtml() in onclick attributes prevents HTML injection but not JS injection — use data-* attributes for externally-sourced values | technique | 10/15 |
| GE-20260421-1eac96 | Three.js r128: Object.assign to a Light's .position throws 'read only property' and silently aborts scene init | gotcha | 9/15 |
| GE-20260421-3460ce | Pre-generate 4 CanvasTexture directional sprite variants at startup — swap .material per frame for zero-cost direction | technique | 11/15 |
| GE-20260421-6d4f16 | Three.js SpriteMaterial has depthWrite:false by default — fog planes render through sprites at low camera angles | gotcha | 11/15 |
| GE-20260421-df549e | Three.js directional sprite selection needs Math.atan2(-dx, dz) — positive dx inverts left/right | gotcha | 9/15 |
| GE-20260422-ae631f | Three.js object.visible = false keeps the object in the scene graph — traversal and frustum culling still run | gotcha | 12/15 |
| GE-20260423-6e8f88 | Profile-aware unit height in Three.js via a single JS variable updated in loadTerrain() | technique | 10/15 |
| GE-20260423-bf2ab1 | Three.js blue-white DirectionalLight dominates MeshLambertMaterial colour — changing tile colour alone does not fix grey appearance | gotcha | 10/15 |
| GE-20260426-90563c | e.preventDefault() on mousedown suppresses the subsequent click event on the same element | gotcha | 11/15 |
| GE-20260508-649308 | Global canvas CSS rule stretches all canvas elements including inline UI canvases | gotcha | 12/15 |
| GE-20260508-f742f6 | Three.js sprites not raycasted until first render frame updates matrixWorld | gotcha | 13/15 |
| GE-20260522-676291 | ResizeObserver triggers updateDiffMap without innerHTML reset — word-diff marks nest on each resize | gotcha | 12/15 |
| GE-20260522-405c25 | Process text nodes in reverse DOM order when splitting them for inline element injection | technique | 11/15 |
| GE-20260522-6786c3 | el.textContent equals concatenation of text nodes in DOM order — use for offset mapping in DOM highlighters | technique | 9/15 |
| GE-20260524-b0a4d9 | marked.js v9 paragraph tokens have rawLines=0 — annotateRendered silently skips all paragraphs | gotcha | 13/15 |
| GE-20260524-d643d9 | marked.lexer v9 distributes trailing newlines between token types — paragraphs get none, headings get all | undocumented | 12/15 |
| GE-20260531-929107 | EventSource.addEventListener('named-event') silently drops all events when server sends unnamed SSE | gotcha | 12/15 |
| GE-20260610-a923a0 | Yarn workspace name collision when Java/Maven project has a package.json claiming an npm namespace | gotcha | 10/15 |
| GE-20260610-615a65 | JS Date.setUTCMonth overflows month-end dates; Java Calendar.add clamps them | gotcha | 10/15 |
| GE-20260612-cd10d7 | JSONata v2 evaluate(data, bindings) — bindings require $ prefix, data paths don't | gotcha | 11/15 |
| GE-20260612-d561ae | exactOptionalPropertyTypes rejects undefined passed to optional properties — conditional object construction required | gotcha | 9/15 |
| GE-20260613-899303 | JSONata v2 auto-unwraps single-element array results into flat values | gotcha | 11/15 |
| GE-20260614-cd8e92 | Playwright CSS locators auto-pierce open Shadow DOM but page.evaluate() raw JS does not | gotcha | 13/15 |
| GE-20260615-d356e6 | HTMLElement.dataset is reserved — Web Components cannot override it with a typed property setter | gotcha | 9/15 |
| GE-20260615-8cd96f | TypeScript generic function re-export cannot widen constraint via declaration merging — use type assertion | technique | 10/15 |
| GE-20260616-e268d7 | Yarn workspace TypeScript monorepo — stale .d.ts silently drops new function parameters | gotcha | 10/15 |
| GE-20260617-0b0dba | renderComponent before addEventListener silently loses all connectedCallback events — no data, no error | gotcha | 14/15 |
| GE-20260617-cc0834 | Shadow DOM keyboard event target is the host element — global shortcut guards miss inner editable fields | gotcha | 10/15 |
| GE-20260618-580486 | NavTree orphaned pages duplicate charts — filtering navTree members is insufficient | gotcha | 10/15 |
| GE-20260618-9ecfa7 | Prometheus JSONata preset: vector and matrix paths apply different label filtering | gotcha | 8/15 |
| GE-20260618-1bcafc | DashBuilder global.dataset.type is stored but never consumed by casehub runtime | undocumented | 9/15 |
| GE-20260621-710dfe | TypeScript rootDir in base tsconfig resolves relative to the base config directory, not the extending config | gotcha | 10/15 |
| GE-20260621-d5e7d4 | Use emitDeclarationOnly with .typecheck outDir for incremental cross-package type checking without JS emission | technique | 10/15 |
| GE-20260621-f9970f | tsc --noEmit works with composite projects but tsc --build --noEmit fails — different emit requirements | undocumented | 10/15 |
| GE-20260621-d98bb2 | Prometheus text parser indexOf('}') breaks on URI path params containing curly braces | gotcha | 10/15 |
| GE-20260621-fe3944 | Table filter event needs both row object and rowIndex — display index differs from dataset index | gotcha | 9/15 |
| GE-20260621-90ec54 | Record navigation silently fails with non-unique idColumn — filter matches multiple rows | gotcha | 8/15 |
| GE-20260621-f0563a | Proxy VizTarget pattern enables multiple dataset requests through single-dataset event pipeline | technique | 9/15 |
| GE-20260622-549a11 | ESLint no-unnecessary-type-assertion conflicts with TSC --build for querySelector in test files | gotcha | 10/15 |
| GE-20260623-06914b | esbuild silently drops Web Component customElements.define() from bare side-effect imports | gotcha | 11/15 |
| GE-20260625-fa01da | history.pushState() during popstate handler creates duplicate history entries — forward navigation breaks | gotcha | 10/15 |
| GE-20260625-4a2d68 | URLSearchParams.get() decodes percent-encoded characters before returning — custom encoding schemes with structural separators break | gotcha | 9/15 |
| GE-20260625-2c2539 | JSDOM location.hash persists across vitest test cases — URL state leaks between tests | gotcha | 12/15 |
| GE-20260626-ec95a0 | npm publish in Yarn 4 monorepo ships literal workspace:* deps — consumers can't resolve them | gotcha | 12/15 |
| GE-20260626-0ac274 | casehub-pages accumulate + expression is a no-op for inline datasets — expression never evaluates | undocumented | 10/15 |
| GE-20260627-9d0123 | Parser condition priority silently converts aggregates to keys when source matches group column | gotcha | 11/15 |
| GE-20260629-a9db51 | ECharts custom series api.value(N) returns 0 for out-of-range indices, not undefined | gotcha | 10/15 |
| GE-20260629-ebdb0a | import type does not trigger customElements.define() — Web Components missing from webpack bundle | gotcha | 11/15 |
| GE-20260630-b8e2d8 | CSS Grid fr tracks don't collapse on display:none — flex automatically redistributes | gotcha | 12/15 |
| GE-20260701-fe7a85 | Light DOM innerHTML re-render silently destroys parent-wired event listeners | gotcha | 12/15 |
| GE-20260702-29cf6c | Cross-stack Content-Type mismatch passes isolated tests but breaks at integration — HTTP 415 | gotcha | 11/15 |
| GE-20260702-b1f919 | Flex cross-axis stretch doesn't cap height — children exceeding container grow the item past its parent | gotcha | 11/15 |
