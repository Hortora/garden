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
| GE-20260704-73bebb | casehub-pages event op silently skips lastSeq tracking — since-based reconnection never fires | undocumented | 10/15 |
| GE-20260705-7c80f2 | Lit @state() Set/Map mutation in-place does not trigger re-render — child components never update | gotcha | 12/15 |
| GE-20260705-1cda0b | Empty string is a valid URL base but fails JavaScript truthiness checks — components silently skip data loading | gotcha | 10/15 |
| GE-20260705-557ee5 | REST response shape mismatch in SSE handler crashes filter pipeline — UI locks up with no visible error | gotcha | 11/15 |
| GE-20260705-9a8478 | AML webui depends on casehub-pages via npm file: protocol — requires specific sibling checkout layout | undocumented | 8/15 |
| GE-20260706-b2804c | Lit Web Component empty-string endpoint silently skips fetch — !this.endpoint vs == null | gotcha | 10/15 |
| GE-20260706-f2a9b2 | Map objects in postMessage appear to work but silently lose data across real iframe boundaries | gotcha | 12/15 |
| GE-20260706-9335b9 | Shadow DOM CSS custom property declarations silently override inherited document-level theme tokens | gotcha | 11/15 |
| GE-20260706-2c7f2b | Non-existent CSS custom property in a shorthand declaration silently invalidates the entire declaration | gotcha | 10/15 |
| GE-20260706-cad45e | Yarn 4 project-level .yarnrc.yml npmScopes overrides home-level entirely — no property merge | gotcha | 10/15 |
| GE-20260706-2ad2b1 | Vitest vi.useFakeTimers() silently replaces vi.stubGlobal() browser API stubs | gotcha | 8/15 |
| GE-20260706-7d5f53 | Yarn 4 npm whoami returns 'No authentication configured' with valid GitHub Packages auth | undocumented | 8/15 |
| GE-20260706-7bb555 | JSDOM clientHeight is always 0 — virtual scroll tests pass with wrong window size | gotcha | 11/15 |
| GE-20260706-dfef71 | CSS Grid column picker inside header grid takes its own column slot — misaligns header and body | gotcha | 9/15 |
| GE-20260707-7fc8b4 | TypeScript strict-mode setter contravariance blocks explicit implements even when class structurally satisfies interface | gotcha | 10/15 |
| GE-20260708-68c961 | response.json().catch() fails when json property is undefined — synchronous TypeError bypasses .catch() | gotcha | 9/15 |
| GE-20260709-2084c9 | Vite dev + esbuild prod dual build: HTML must reference .ts source, not .js bundle — ESM script 404 is silent | gotcha | 8/15 |
| GE-20260709-e611d2 | Vite-only path aliases break esbuild production builds — re-exports from aliased packages fail silently in dev but hard-fail in prod | gotcha | 9/15 |
| GE-20260710-136291 | Lit css tagged template rejects raw strings — must use css`` result not backtick strings | gotcha | 9/15 |
| GE-20260710-fe9f97 | globalThis.fetch override in SPA page components clobbers mock routing on navigation | gotcha | 9/15 |
| GE-20260710-e663d5 | as never over as any for narrow TypeScript type assertions — satisfies constraint without widening | technique | 8/15 |
| GE-20260710-8f380d | TypeScript mixin Constructor<> intersection cannot express protected — methods must be public in return type | undocumented | 9/15 |
| GE-20260710-335228 | Vite/Vitest object-format aliases silently miss regex-dependent deep imports | gotcha | 10/15 |
| GE-20260710-77483b | Two-cache-field pattern prevents precedence violation in multi-source Lit mixins | technique | 10/15 |
| GE-20260710-e58db6 | TypedRow.cell() is safe (discriminated union), TypedRow.number() throws on NULL or type mismatch | undocumented | 10/15 |
| GE-20260711-5170ee | pages-data extractDataSet throws EMPTY_RESULT on empty arrays — blocks empty-state rendering in fetchSource consumers | gotcha | 8/15 |
| GE-20260712-0b3483 | Vite object-form aliases match shorter prefix first — /dist deep imports resolve to wrong src/dist/ path | gotcha | 9/15 |
| GE-20260712-ab4f0a | esbuild alias prefix replacement breaks /dist deep imports — point to package root not /src for production builds | gotcha | 8/15 |
| GE-20260712-f5b872 | CSS custom properties cascade through shadow DOM but theme class + style must be on the host element | technique | 8/15 |
| GE-20260712-7250c5 | DataSourceMixin extraction pipeline destroys non-tabular domain responses | gotcha | 11/15 |
| GE-20260713-b35869 | PointerEvent timeStamp near-zero in jsdom causes velocity false-positives | gotcha | 11/15 |
| GE-20260713-9e6bf5 | jsdom composedPath() does not cross Shadow DOM boundaries — click-outside detection fails in tests | gotcha | 11/15 |
| GE-20260713-777d8a | Shadow DOM document.activeElement returns host — focus comparisons silently fail across shadow boundaries | gotcha | 8/15 |
| GE-20260713-44a60b | jsdom never fires animationend — components using CSS animation callbacks hang in tests | gotcha | 8/15 |
| GE-20260714-cdd0f2 | tsc composite build with stale .tsbuildinfo silently emits no .js files — exit code 0, no warning | gotcha | 13/15 |
| GE-20260714-b6ec65 | Reactive data pipeline refresh-via-onChanged creates infinite recursion when refresh semantics change from cache-serve to re-fetch | gotcha | 11/15 |
| GE-20260715-dad5e5 | vitest watch mode in package.json test script hangs yarn workspaces foreach | gotcha | 8/15 |
| GE-20260715-86e5d6 | globalThis.fetch override in SPA example page poisons all subsequent routes | gotcha | 9/15 |
| GE-20260612-d561ae | exactOptionalPropertyTypes rejects undefined passed to optional properties — conditional object construction required | gotcha | 9/15 |
| GE-20260716-424a17 | Native <select> popup displaced in deeply nested shadow DOM with scrolled containers | gotcha | 11/15 |
| GE-20260717-4618a1 | Shadow DOM CSS scoping silently breaks callback-rendered content in web component composition | gotcha | 11/15 |
| GE-20260717-c99f50 | TypedRow passed as Lit property looks like a plain object but direct property access returns undefined | gotcha | 9/15 |
| GE-20260717-02208c | pages-ui-tokens generates --pages-{name}-{1..12} only — no -contrast suffix tokens | gotcha | 8/15 |
| GE-20260712-7250c5 | DataSourceMixin extraction pipeline destroys non-tabular domain responses | gotcha | 11/15 |
| GE-20260717-19540a | esbuild TC39 decorator pass-through breaks Lit @state()/@property() in Chromium 138+ — page renders blank | gotcha | 13/15 |
| GE-20260717-6610cc | CSS positioning class defined but never applied — dead fallback looks complete | gotcha | 10/15 |
| GE-20260717-8e8a6b | Vanilla Web Component setter-triggered render ignores callbacks set after dataSet | gotcha | 9/15 |
| GE-20260718-b097b3 | Playwright locator.textContent() returns empty string for nested LitElement Shadow DOM — locator selection pierces but extraction methods don't | gotcha | 14/15 |
| GE-20260718-d22748 | Yarn workspace hoisting masks circular cross-package dependencies — TS2307 only in CI | gotcha | 11/15 |
| GE-20260719-4db710 | CSS Grid single-container virtual scroll — native spanning without position hacks | technique | 11/15 |
| GE-20260720-9c817e | Cross-repo Vite alias pattern for consuming unpublished npm packages from sibling repos | technique | 9/15 |
| GE-20260720-96fab8 | Barrel re-exports couple side-effect modules — causes duplicate customElements.define() in aliased bundler setups | gotcha | 11/15 |
| GE-20260720-a60eec | Lit updateComplete resolves before async buildOption Promise — chart mock assertions see 0 calls | gotcha | 11/15 |
| GE-20260720-80f6e1 | LitElement connectedCallback + willUpdate double-fires data requests when @property set before DOM insertion | gotcha | 10/15 |
