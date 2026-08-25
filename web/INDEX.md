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
| GE-20260720-ebe1cd | onPagesEvent callback receives payload directly — treating it as a CustomEvent gives misleading undefined errors | gotcha | 10/15 |
| GE-20260721-c8a94f | EventSource SSE client tracking race during Lit view navigation — waitForSSEClient resolves on stale connection | gotcha | 8/15 |
| GE-20260721-f094e6 | TypeScript mixin rejects abstract class — Constructor<T> requires concrete new() | gotcha | 9/15 |
| GE-20260723-09e6d9 | DOM structure tests pass while CSS layout is wrong — Web Component test gap | gotcha | 10/15 |
| GE-20260725-174b2c | vitest mockResolvedValue reuses same Response object — body read fails on second fetch | gotcha | 8/15 |
| GE-20260727-0e1c60 | Webpack aliases bypass sideEffects package.json resolution — side-effect imports tree-shaken despite correct declaration | gotcha | 11/15 |
| GE-20260727-e642b2 | pages-table row-activate event carries { row, key }, not { index } | gotcha | 12/15 |
| GE-20260728-6d585d | Lit ESM bundles fail dynamic import in Node.js — createTreeWalker called at module init | gotcha | 11/15 |
| GE-20260729-47f58b | pages-table selectedKeys silently ignored without selection attribute — no visual row highlighting | gotcha | 10/15 |
| GE-20260729-f3f3a1 | CommitmentStatePill double registration — blocks-ui-core and commitment-viz both define @customElement('commitment-state-pill') | gotcha | 11/15 |
| GE-20260730-d646b7 | Ship pre-built static assets alongside tree-shakeable ESM for web component libraries | technique | 10/15 |
| GE-20260730-ec4b06 | Native Popover API + CSS Anchor Positioning replaces JS popover stack in Lit shadow DOM | technique | 9/15 |
| GE-20260801-36b9fa | Cytoscape.js has no public API for custom canvas-drawn node shapes | gotcha | 10/15 |
| GE-20260801-bda7a8 | @xyflow/system is an internal utility layer, not a standalone rendering framework | gotcha | 9/15 |
| GE-20260801-d3e4fe | React-in-Lit bridge pattern — mount React libraries inside Lit Web Components | technique | 10/15 |
| GE-20260801-355ce5 | CSS all:initial resets custom properties — design tokens must be explicitly re-declared | gotcha | 9/15 |
| GE-20260802-953404 | CSS @layer provides no isolation from unlayered host CSS — unlayered declarations win in the cascade | gotcha | 11/15 |
| GE-20260802-19843a | React Flow v12 NodeTypes uses { data: any; type: any } widening — ComponentType<NodeProps> is not assignable | gotcha | 8/15 |
| GE-20260801-d3e4fe | React-in-Lit bridge pattern — mount React libraries inside Lit Web Components | technique | 10/15 |
| GE-20260803-17fc03 | casehub-packages directory names don't match npm package names — esbuild 'Could not resolve' when importing by directory path convention | gotcha | 8/15 |
| GE-20260803-1f9860 | jsdom does not provide ResizeObserver — Lit components throw ReferenceError in vitest with no hint at the missing API | gotcha | 9/15 |
| GE-20260803-a1ac7f | Split useEffect into render + cleanup when bridging lit-html into React — single effect destroys diffing | technique | 10/15 |
| GE-20260803-9ce4f2 | exactOptionalPropertyTypes rejects parentId: undefined — use conditional spread instead | gotcha | 8/15 |
| GE-20260803-498245 | json-schema-to-typescript index signature conflicts with named properties under exactOptionalPropertyTypes | gotcha | 9/15 |
| GE-20260803-50ddbd | createReactNodeType — bridge lit-html templates into React Flow custom nodes via useRef + litRender | technique | 10/15 |
| GE-20260803-cdec3c | happy-dom adoptNode round-trip fails: Cannot redefine property ownerDocument | gotcha | 8/15 |
| GE-20260804-d6b186 | Stale workspace:* dist hides missing exports — runtime undefined function | gotcha | 9/15 |
| GE-20260804-31bdba | Declared but uninstalled npm dependency — partial test suite masks total failure | gotcha | 8/15 |
| GE-20260804-f4e13a | xterm.js renders invisible inside Lit shadow DOM — CSS isolation hides viewport | gotcha | 11/15 |
| GE-20260804-4d9ce7 | Document-level mousedown bypasses nested shadow DOM focus barrier for xterm.js | technique | 10/15 |
| GE-20260804-96c692 | renderNode child recursion is gated by LAZY_TYPES, not LAYOUT_TYPES — non-layout types with slots render children eagerly | gotcha | 11/15 |
| GE-20260804-64c599 | SSE EventSource sends message type, not named events — addEventListener misses them | gotcha | 10/15 |
| GE-20260804-50d971 | pages-data-table paginated mode fills parent height — must wrap in constrained div | undocumented | 8/15 |
| GE-20260804-a89d3b | pages-runtime loadSite pulls entire transitive dependency chain — js-yaml, marked, echarts | gotcha | 9/15 |
| GE-20260804-0959d2 | work-item-inbox has no compact mode — use list-pane for dock panels | gotcha | 8/15 |
| GE-20260804-befd45 | Pages dockWorkbench decomposes into 3 primitives — no monolithic Web Component | technique | 11/15 |
| GE-20260804-84ac70 | life-ui layout via Pages DSL — dockWorkbench + hostPanel + loadSite, not custom Lit components | convention | 8/15 |
| GE-20260804-c15f1f | Lit @property does not reflect String properties to HTML attributes by default — CSS :host([attr]) selectors silently fail | gotcha | 9/15 |
| GE-20260804-24d409 | Lit @customElement tag mismatch silently degrades — no error, no warning, visually masks broken UI | gotcha | 11/15 |
| GE-20260804-52ba5f | SSE addEventListener for named events silently ignores unnamed server events — use onmessage | gotcha | 14/15 |
| GE-20260804-149db1 | Quarkus Quinoa dev mode serves stale frontend — manual yarn build does not update served files | gotcha | 10/15 |
| GE-20260805-e3211c | pages-runtime hostPanel resolves custom elements via registerPanel — import AND register before loadSite | technique | 9/15 |
| GE-20260805-0f01a5 | TypeScript barrel re-export pulls in browser-only module — ReferenceError: document is not defined in Node test environments | gotcha | 9/15 |
| GE-20260805-aa8a88 | buildFlatGraph() synthetic container nodes cause false integrity mismatches | gotcha | 14/15 |
| GE-20260805-4091ab | buildFlatGraph() throws unclear error on invalid SWF flow directives | gotcha | 12/15 |
| GE-20260805-d1044d | buildFlatGraph() nested try: subtask IDs omit /do/ path segment | gotcha | 14/15 |
| GE-20260805-bdbc53 | Dual-walk pattern for SDK-backed domain adapters with degraded mode | technique | 14/15 |
| GE-20260806-82b68b | Dockview v7 floating group DOM structure — .dv-resize-container outermost, .dv-floating-titlebar for chrome injection | undocumented | 8/15 |
| GE-20260806-9c391c | Dockview vitest mock missing .panels property — optional chaining required for any unmocked API | gotcha | 8/15 |
| GE-20260806-625f46 | Dockview v7 createTabComponent factory for custom tab hover behaviour | technique | 9/15 |
| GE-20260806-10d369 | blocks-ui-core EventStreamController is WebSocket-based, not SSE — use SSEManager from pages-data for actual SSE | gotcha | 9/15 |
| GE-20260806-1f881e | pages-data SSEManager eventNames filters SSE protocol-level named events only — JSON payload type field requires client-side filtering | undocumented | 9/15 |
| GE-20260806-d34211 | TypeScript composite mode emits TS4094 for private/protected members on exported Lit mixin classes | gotcha | 11/15 |
| GE-20260808-a59625 | pages-ui dockWorkbench distributes columns equally — dock panels get 33% width on wide screens | gotcha | 12/15 |
| GE-20260809-6bede4 | Dockview overlay.toJSON() switches CSS anchoring after drag — top becomes undefined | gotcha | 12/15 |
| GE-20260809-44b2a6 | Dockview addPanel floating position clamped to zero when container unsized in Lit firstUpdated | gotcha | 13/15 |
| GE-20260809-f0c43a | happy-dom getBoundingClientRect returns zeros — Dockview mock tests give false confidence | gotcha | 12/15 |
| GE-20260809-6821a6 | Dockview smooth tab reorder (tabAnimation:'smooth') does not fire onDidDrop | gotcha | 11/15 |
| GE-20260809-24b35e | Vite oxc transform fails with 'Tsconfig not found' when aliasing monorepo sibling packages to src/ | gotcha | 9/15 |
| GE-20260809-778096 | Setting Lit @state() inside updated() triggers second render — await updateComplete resolves too early in tests | gotcha | 8/15 |
| GE-20260809-2cbc61 | ReactFlow is wrong for force-directed graph rendering — use D3 SVG directly | gotcha | 9/15 |
| GE-20260809-f1c2c6 | Lit updated() with @state() triggers double render — D3 setup must wait for second cycle | gotcha | 8/15 |
| GE-20260809-a11928 | D3 force simulation as layout companion for Lit Web Components | technique | 10/15 |
| GE-20260809-a51226 | Relationship type registry follows status registry pattern — module-level Map, no deregistration | convention | 8/15 |
| GE-20260809-fd314e | restoreFromUrl hides shared slot — hides all panels, not just the closed one | gotcha | 11/15 |
| GE-20260809-ae2695 | style.setProperty uses CSS hyphenated names, not camelCase JS names | gotcha | 12/15 |
| GE-20260809-e37216 | IntelliJ MCP returns empty indexes for slot-cloned TS projects without .idea | gotcha | 10/15 |
| GE-20260809-646d55 | Renderer slot containers break flex height chains — need explicit flex styling | gotcha | 11/15 |
| GE-20260809-aee002 | resolveDockZone — middle vs bottom position maps to different zones | gotcha | 9/15 |
| GE-20260809-14d2f9 | Playwright visual TDD — getBoundingClientRect assertions for layout verification | technique | 11/15 |
| GE-20260809-c32008 | Deferred dock panels need data-pages-display=flex for content stretching | undocumented | 10/15 |
| GE-20260809-cfb423 | Zone naming convention: side-position for columns, position-side for bottom bar | convention | 8/15 |
| GE-20260810-46121c | npm ci silently creates dangling symlinks from package-lock.json link:true entries — exits 0 with broken node_modules | gotcha | 12/15 |
| GE-20260810-33cc57 | Quinoa package-manager-command property is appended to npm — cannot switch to yarn or other package managers | gotcha | 9/15 |
| GE-20260810-6309f5 | esbuild alias resolves package root but external sources need nodePaths to find their dependencies | gotcha | 9/15 |
| GE-20260810-918a14 | npm ignores package.json resolutions field entirely — portal: links are Yarn-only | undocumented | 8/15 |
| GE-20260810-cfc53d | casehub-pages buildDataSetScope creates static scope at loadSite() — no runtime dataset mutation API | undocumented | 8/15 |
| GE-20260810-8f3127 | Lit @state on parent survives child unmount/remount — ghost selection state when switching views | gotcha | 9/15 |
| GE-20260810-0393bf | Three-way client-side join for composite views — load independent endpoints in parallel, merge by shared key, degrade independently | technique | 9/15 |
| GE-20260810-9fff4b | Filter toggle-off pattern — clicking an active filter button returns to 'All' instead of being a no-op | convention | 8/15 |
| GE-20260810-07c717 | TypeScript readonly interface spread loses required properties | gotcha | 8/15 |
| GE-20260810-e12c27 | Dockview v7 createComponent receives {id, name} only — user params arrive at init(params.params) | gotcha | 13/15 |
| GE-20260810-91bdd1 | casehub-pages renderComponent clears target innerHTML — loop over children destroys all but last | gotcha | 10/15 |
| GE-20260810-4ae500 | Absolute overlay inside content-sized parent gets content height, not flex space | gotcha | 9/15 |
| GE-20260810-7c5ae9 | Dockview v7 grid element has opaque theme background — must override for overlay use | gotcha | 9/15 |
| GE-20260810-8a1c41 | npm file: protocol installs devDependencies of linked packages — cascading 404s for private-registry deps | gotcha | 11/15 |
| GE-20260810-5f4dbe | Yarn resolutions field in package.json is silently ignored by npm — use overrides instead | gotcha | 10/15 |
| GE-20260810-c90963 | npx --prefix sets module resolution path but does NOT change working directory | gotcha | 9/15 |
| GE-20260810-9ba5de | Conditional vite aliases with fs.existsSync() for multi-environment compatibility | technique | 9/15 |
| GE-20260810-81d356 | CSS grid grid-auto-rows minmax(min-content, 1fr) with height:100% stretches ALL rows equally | gotcha | 10/15 |
| GE-20260810-8df51b | LitElement custom elements default to display:inline — silently ignores height and min-height | gotcha | 9/15 |
| GE-20260810-696ea3 | ECharts new chart types require registration in 3 separate type maps — missing any silently falls back to data-table | technique | 9/15 |
| GE-20260810-f7b20c | ECharts treemap parent nodes with explicit value:0 override child auto-sum — renders single blank rectangle | gotcha | 8/15 |
| GE-20260810-8ad59a | DockviewBackend injects CSS into document.head — invisible in shadow DOM host | gotcha | 10/15 |
| GE-20260810-ccd128 | FloatingFrameEngine captureLayout returns stale creation-time positions after drag/resize | gotcha | 10/15 |
| GE-20260810-2f9a5a | DockviewBackend injectFrameChrome silently fails before DOM ready — no retry | gotcha | 9/15 |
| GE-20260811-ff622d | Dockview floating group titlebar is a sibling of groupview, not a child | gotcha | 9/15 |
| GE-20260811-117018 | pointer-events:none on overlay containers silently blocks clicks on dynamically appended children | gotcha | 9/15 |
| GE-20260811-f9c6f1 | LitElement @property named nodeType collides with DOM Node.nodeType — decorator error misleads toward CustomElementClass | gotcha | 9/15 |
| GE-20260812-5cd146 | pages-data EventConnection silently drops non-event wire messages | gotcha | 10/15 |
| GE-20260812-da1f97 | vitest discovers tests through npm file: symlinks into vendored packages | gotcha | 9/15 |
| GE-20260812-a0d705 | Barrel re-export pulls in unavailable transitive dependency from unused module | technique | 8/15 |
| GE-20260813-674be0 | casehub-pages YAML desugarer drops unknown component props silently | gotcha | 9/15 |
| GE-20260813-c50d64 | exactOptionalPropertyTypes blocks undefined assignment to optional fields — use delete | gotcha | 8/15 |
| GE-20260814-51d2dd | Lit updated() fires before shadow DOM canvas is drawable — requestAnimationFrame needed for conditional canvas rendering | gotcha | 9/15 |
| GE-20260814-2beabf | Canvas crosshair position shifts when Lit panel resize changes canvas container width | gotcha | 10/15 |
| GE-20260814-0cd075 | Quarkus Quinoa dev mode does not hot-reload TypeScript source changes — requires clean rebuild | gotcha | 8/15 |
| GE-20260814-85714a | HTML overlay divs for pixel-perfect canvas interaction — immune to container resize | technique | 8/15 |
| GE-20260814-fc5487 | npm file: tarball deps need overrides to prevent registry lookups for transitive @casehubio packages | gotcha | 9/15 |
| GE-20260814-37b0ed | Pages restSource needs dataPath to unwrap paginated API responses — dataTable shows No data otherwise | gotcha | 9/15 |
| GE-20260814-c7c5e9 | Pages LiveSite.navigate(tabLabel) for programmatic tab switching — no selectTab() exists | undocumented | 8/15 |
| GE-20260814-0d4123 | casehub-pages first tab shows 'No data' — renderInitialSlot never fires pages-slot-change | gotcha | 12/15 |
| GE-20260815-ac6e89 | Content preserved across layout toggle via detach/reattach — not destroy/recreate | technique | 13/15 |
| GE-20260816-5c4812 | jsdom setAttribute on aria-expanded does not reflect via getAttribute on non-form elements | gotcha | 10/15 |
| GE-20260816-290024 | ECharts aria.enabled can be injected at the abstract base class level via option mutation | technique | 8/15 |
| GE-20260816-e89cda | Composable Lit reactive controllers with explicit dependency chain for shared channel state | technique | 9/15 |
| GE-20260817-2dcaae | Async functions in synchronous event handlers break test assertions | gotcha | 10/15 |
| GE-20260818-f0257a | Shadow-aware CSS injection with per-root WeakMap ref-counting for web component libraries | technique | 9/15 |
| GE-20260818-66b0ca | Lit @state() does not reflect to ARIA — dynamic aria-busy/aria-disabled/aria-expanded need manual setAttribute in render() | gotcha | 9/15 |
| GE-20260818-87ba6b | ARIA source-grep validation gives false positives for shadow DOM internal ARIA — host element has no ARIA attributes | gotcha | 9/15 |
| GE-20260819-96e032 | pages-ui html() DSL uses innerHTML — cannot pass complex properties to hosted web components | technique | 10/15 |
| GE-20260819-1b3181 | pages-ui masterDetail() referenced in source but absent from compiled SNAPSHOT | undocumented | 8/15 |
| GE-20260819-fe9c37 | Vite alias + cross-repo node_modules causes duplicate Lit custom element registration | gotcha | 8/15 |
| GE-20260820-1fc6bc | blocks-approval-gate accepts arbitrary OutcomeDefinition[] — not locked to approve/reject | undocumented | 8/15 |
| GE-20260821-2b0612 | Vite pre-bundle cache ignores Yarn portal dependency source changes | gotcha | 8/15 |
| GE-20260821-1a90cd | ReactFlow top-left fit via reactive store bounds subscription | technique | 10/15 |
| GE-20260821-d61150 | Lit @property/@state decorators fail in Vitest unless both esbuild tsconfigRaw AND tsconfig.json set experimentalDecorators | gotcha | 8/15 |
| GE-20260821-05fb0e | EventConnection from pages-data doesn't expose eventTarget — components must accept it as a separate parameter | gotcha | 8/15 |
| GE-20260821-b6af20 | Async initial-state fetch races with synchronous push wire events — stale REST response overwrites real-time state | gotcha | 9/15 |
| GE-20260822-dd986e | PagesElement render gate blocks standalone usage — data property does not bypass | gotcha | 11/15 |
| GE-20260823-590f19 | Pages gallery new component type requires three separate registration points | gotcha | 12/15 |
| GE-20260823-211f3e | WebJar SNAPSHOT portal staleness breaks Lit class hierarchy across packages | gotcha | 10/15 |
| GE-20260823-324804 | blocks-audit-trail-viewer hardcodes platform URL pattern — unusable for app-specific endpoints | gotcha | 9/15 |
| GE-20260823-a02b08 | pages page() nested children need interactive container for navigation — shared path segment | undocumented | 8/15 |
| GE-20260825-6f8a9e | Container replaceChild cascade-collapse — remove/add decomposition triggers onCollapse mid-swap | gotcha | 11/15 |
| GE-20260825-7dc5d2 | Strategy factory selective callback routing — onCollapse only reached split, not tabbed or accordion | gotcha | 8/15 |
| GE-20260825-6e519a | refreshEntry pattern — surgical container replanting via mutate-in-place + re-render | technique | 11/15 |
| GE-20260825-309197 | Design multi-phase interaction state machines as standalone coordinators — closure coupling prevents later extraction | technique | 11/15 |
| GE-20260825-a455eb | Push-wire dispatch messages override executor speed — stale speed after runTo | gotcha | 9/15 |
