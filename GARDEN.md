**Last legacy ID:** GE-0180
**Last full DEDUPE sweep:** 2026-04-14
**Entries merged since last sweep:** 0
**Drift threshold:** 10
**Last staleness review:** 2026-04-14

## By Technology

### apache-jexl/
- GE-20260412-2523eb [JEXL3 `${var}` inside single-quoted string literals is not interpolated — literal text output](apache-jexl/jexl3.md)
### approaches/
- GE-20260412-e51f12 [Varargs type-capture for type-safe DSL methods with full generic support](approaches/java-dsl-design.md)
### casehub-engine/
- GE-0167 [`StateContextImpl.evalObjectTemplate()` is a full mini-template DSL — not JQ](casehub-engine/GE-0167.md)
### beautifulsoup/
- GE-0008 [BeautifulSoup lxml parser double-encodes non-ASCII when input str contains `<meta charset>`](beautifulsoup/GE-0008.md)
- GE-0016 [Hardcoded path traversal fails silently when scanning file copies in an alternate directory](beautifulsoup/GE-0016.md)
- GE-0017 [`html.parser` does not add `<body>` wrapper to fragments; `.body.next` returns None](beautifulsoup/GE-0017.md)
- GE-0131 [BeautifulSoup `get_text()` silently drops `<br/>` tags — multi-line content collapses to one line](beautifulsoup/GE-0131.md)
### claude-code/
- GE-0001 [Claude Code settings.json rejects unknown top-level fields despite additionalProperties schema](claude-code/GE-0001.md)
- GE-0160 [Claude Code `/private/tmp` fills during parallel subagents — ENOSPC on git commit despite free disk](claude-code/GE-0160.md)
### drools/
- GE-0056 [Drools 10 Rule Units DRL: three silent syntax traps with Java records and OOPath patterns](drools/GE-0056.md)
- GE-0057 [`addParamsFact()` must be called at build time — silent wrong-fact extraction at runtime](drools/GE-0057.md)
- GE-0063 [`DataSource.createStore()` fails with NullPointerException in plain JUnit when using `drools-quarkus`](drools/GE-0063.md)
- GE-0105 [Drools as Action Compiler for GOAP — One Session per Tick, Not per A* Node](drools/GE-0105.md)
- GE-0109 [Phase 2 Rules Silently Don't Fire When Depending on List Mutated by Phase 1](drools/GE-0109.md)
### intellij-platform/
- GE-0079 [PostprocessReformattingAspect Adds Spurious Space in Annotation Attributes After PSI Write](intellij-platform/GE-0079.md)
- GE-0080 [renamePsiElementProcessor Requires order="first" for getPostRenameCallback to Fire](intellij-platform/GE-0080.md)
- GE-0081 [Raw PsiElement References Collected in prepareRenaming() Are Invalidated by the Rename Write Action](intellij-platform/GE-0081.md)
- GE-0093 [FQN Resolution Inside FileBasedIndexExtension Causes Recursive Index Read and Crash](intellij-platform/GE-0093.md)
- GE-0110 [`localInspection` in plugin.xml Requires `implementationClass` and Explicit `shortName`](intellij-platform/GE-0110.md)
- GE-0111 [`intellij-platform-gradle-plugin` 2.x Auto-Sets `untilBuild` to `sinceBuild.*`, Blocking Newer IDEs](intellij-platform/GE-0111.md)
- GE-0112 [`SafeDeleteProcessorDelegate.shouldDeleteElement()` Removed in 2023.2 — Use `findConflicts()`](intellij-platform/GE-0112.md)
- GE-0116 [Custom `FileBasedIndexExtension` Not Populated After `addFileToProject()` in `BasePlatformTestCase`](intellij-platform/GE-0116.md)
- GE-0117 [`RenameHandler` Intercepts Before `RenamePsiElementProcessor.substituteElementToRename()` Is Called](intellij-platform/GE-0117.md)
- GE-0119 [PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated](intellij-platform/GE-0119.md)
- GE-0120 [`FindUsagesManager` Has a Public Constructor and Accepts `FindUsagesHandlerBase` Directly](intellij-platform/GE-0120.md)
- GE-0163 [`PsiParameter` does not extend `PsiMember` — use `getDeclarationScope()` to get the containing method](intellij-platform/GE-0163.md)
- GE-0164 [`Messages.showDialog()` auto-selects first option in IntelliJ headless test environment](intellij-platform/GE-0164.md)
- GE-0165 [IntelliJ MCP `ide_index_status` errors when multiple projects are open without `project_path`](intellij-platform/GE-0165.md)
### java/
- GE-20260415-3cf4db [RestAssured GPath 'find { it == [x, y] }' matches int[] inside List<int[]> by value](java/GE-20260415-3cf4db.md)
- GE-20260415-e112ca [Interface default no-op methods for optional lifecycle callbacks — implementors only override what they need](java/GE-20260415-e112ca.md)
- GE-20260415-5d762b [Arrays.copyOf on boolean[][] only copies references — inner rows still shared (mutable aliasing)](java/GE-20260415-5d762b.md)
- GE-0004 [Use typed element return in generator/predicate pairs to enforce cross-API type agreement](java/GE-0004.md)
- GE-0023 [Java records with `List<T>` fields are not truly immutable without a compact constructor](java/GE-0023.md)
- GE-0024 [Multiple `volatile` fields read without synchronisation produce torn cross-field snapshots](java/GE-0024.md)
- GE-0037 [Inject a Supplier<Instant> to test time-dependent logic without sleeping or mocking frameworks](java/GE-0037.md)
- GE-0058 [Wrong generic type parameters in Java stub methods compile silently](java/GE-0058.md)
- GE-0064 [Maven aggregator pom requires `<packaging>pom</packaging>` — omitting it causes a cryptic build failure](java/GE-0064.md)
- GE-0067 [Maven ignores non-Java files in `src/main/java/` — resources must be in `src/main/resources/` or explicitly declared](java/GE-0067.md)
- GE-0122 [`package-private` Members in `a.b.c` Are Inaccessible from `a.b` — Sub-Packages Are Distinct Packages](java/GE-0122.md)
- GE-0139 [`synchronized(key.intern())` causes JVM-wide global pool contention across unrelated instances](java/GE-0139.md)
- GE-0143 [`final hashCode()` in parent — update the protected field from setters instead of overriding](java/GE-0143.md)
- GE-0144 [Maven incremental build passes but `NoClassDefFoundError` at runtime — stale `.class` files](java/GE-0144.md)
- GE-0158 [Use `mvn compile` to enumerate all call sites when changing a Java record signature](java/GE-0158.md)
- GE-20260416-39d854 [Synthesised delegation methods need explicit `public` when overriding interface methods](java/GE-20260416-39d854.md)
- GE-20260416-b57ee4 [JavaParser NodeList.clone() returns raw Object — clone each element individually](java/GE-20260416-b57ee4.md)
### java-panama-ffm/
- GE-0038 [Panama FFM native write/read on PTY slave fds causes SIGTRAP JVM crash in the next test class (macOS AArch64)](java-panama-ffm/GE-0038.md)
- GE-0053 [Panama FFM `IOC_OUT` ioctl returns success but leaves buffer zeroed (macOS AArch64, JVM mode)](java-panama-ffm/GE-0053.md)
- GE-0060 [tput silently reports 0 when TERM env var is absent in PTY integration tests](java-panama-ffm/GE-0060.md)
- GE-0061 [Use tput to verify PTY window dimensions in JVM-mode Panama FFM tests](java-panama-ffm/GE-0061.md)
- GE-20260412-dc1548 [jextract upcall helpers (allocate()) fail silently in native image](java-panama-ffm/native-image-patterns.md)
- GE-20260412-e00a2f [reachability-metadata.json foreign section uses "directUpcalls" not "upcalls"](java-panama-ffm/native-image-patterns.md)
- GE-20260412-c15261 [Arena.ofAuto() throws UnsupportedOperationException on close()](java-panama-ffm/native-image-patterns.md)
- GE-20260412-73b00b [jextract-generated classes initialize at build time and fail to find dylib symbols](java-panama-ffm/native-image-patterns.md)
- GE-20260412-e103a8 [Hand-written Panama FFM classes with static final MethodHandle fields also need --initialize-at-run-time](java-panama-ffm/native-image-patterns.md)
- GE-20260412-937f1d [MissingForeignRegistrationError gives no indication which downcall entry is wrong](java-panama-ffm/native-image-patterns.md)
### macos-native-appkit/
- GE-0051 [Smoke-test WKWebView rendering by checking for a new WebContent process](macos-native-appkit/GE-0051.md)
- GE-0072 [`performSelectorOnMainThread:waitUntilDone:NO` from main thread schedules asynchronously](macos-native-appkit/GE-0072.md)
- GE-0073 [NSEvent local monitor + BOOL flag for mode-based key interception](macos-native-appkit/GE-0073.md)
### permuplate/
- GE-0005 [@PermuteReturn methods with hand-written return types silently disappear via boundary omission](permuplate/GE-0005.md)
- GE-0007 [typeArgList(from, to, style) accepts dynamic JEXL expressions for from/to, not just constants](permuplate/GE-0007.md)
- GE-20260416-17bdf4 [PermuteTypeParamTransformer must run BEFORE applySourceTypeParams — type param doubling](permuplate/GE-20260416-17bdf4.md)
- GE-20260416-f316e2 [@PermuteSource must be stripped from generated output or causes cannot-find-symbol](permuplate/GE-20260416-f316e2.md)
- GE-20260416-9d1147 [PermuteMojo generate() chain handles composition ordering in-memory — no extra infrastructure](permuplate/GE-20260416-9d1147.md)
### quarkus/
- GE-20260415-5c2136 [@QuarkusTest binds hardcoded port 8081 — add test-port=0 to prevent 'Port already bound' cascades](quarkus/GE-20260415-5c2136.md)
- GE-0031 [`<packaging>quarkus</packaging>` in pom.xml is non-standard and causes tooling issues — Quarkus doesn't generate it](quarkus/GE-0031.md)
- GE-0032 [Quarkus `@Scheduled` allows overlapping executions by default — no warning, just a race](quarkus/GE-0032.md)
- GE-0033 [Use `@UnlessBuildProfile("prod")` to strip debug/QA beans from production at CDI level](quarkus/GE-0033.md)
- GE-0036 [@ApplicationScoped bean state accumulates across @QuarkusTest classes in the same run](quarkus/GE-0036.md)
- GE-0045 [Quarkus WebAuthn config keys use wrong names — silently ignored, no warning](quarkus/GE-0045.md)
- GE-0046 [WebAuthn session cookie encryption key is `quarkus.http.auth.session.encryption-key` — not documented in WebAuthn extension docs](quarkus/GE-0046.md)
- GE-0047 [Use javap to find the actual Quarkus config property name from a field annotation](quarkus/GE-0047.md)
- GE-0052 [`@UnlessBuildProfile` has undocumented `anyOf` attribute for multi-profile exclusion](quarkus/GE-0052.md)
- GE-0062 [`HttpAuthenticationMechanism` injections resolve before `@Observes StartupEvent` fires](quarkus/GE-0062.md)
- GE-0065 [Quarkus `quarkus:dev` silently skips and returns BUILD SUCCESS if the `build` goal is missing from plugin executions](quarkus/GE-0065.md)
- GE-0066 [`@UnlessBuildProfile` on a bean causes "Unsatisfied dependency" in any bean that injects it without a matching profile guard](quarkus/GE-0066.md)
- GE-0068 [Quarkus Flow `consume` steps re-deserialize input — mutable mutations don't propagate](quarkus/GE-0068.md)
- GE-0069 [Quarkus Flow: plain mutable POJO as workflow input → `FAIL_ON_EMPTY_BEANS` at runtime](quarkus/GE-0069.md)
- GE-0070 [Quarkus Flow `listen` task does not receive from SmallRye in-memory channels](quarkus/GE-0070.md)
- GE-0071 [Bridge SmallRye in-memory channel to Quarkus Flow using @Incoming + startInstance()](quarkus/GE-0071.md)
- GE-0076 [-D Flags After -jar Don't Override Config Expressions in Quarkus](quarkus/GE-0076.md)
- GE-0077 [Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean](quarkus/GE-0077.md)
- GE-0078 [Quarkus WebAuthn Actual HTTP Endpoint Paths (Only Discoverable via Bytecode)](quarkus/GE-0078.md)
- GE-0094 [@QuarkusTest HTTP endpoint tests fire real @ApplicationScoped beans — including side-effectful adapters](quarkus/GE-0094.md)
- GE-0095 [Use a dedicated @QuarkusTest class with @InjectMock to isolate side-effectful endpoint tests](quarkus/GE-0095.md)
- GE-0104 [Authenticator.publicKeyAlgorithm has no getter/setter — field cannot be persisted in WebAuthnUserProvider](quarkus/GE-0104.md)
- GE-0123 [Use Java-Managed Event Buffers + Fresh RuleUnitInstance per Tick Instead of Drools Fusion STREAM Mode for Temporal CEP in Quarkus Rule Units](quarkus/GE-0123.md)
- GE-0125 [Quarkus static files are embedded in the JAR — source changes require a full rebuild to take effect](quarkus/GE-0125.md)
- GE-0126 [Quarkus WebAuthn generates a new random session key on restart — REST APIs return 401, WebSocket stays alive](quarkus/GE-0126.md)
- GE-0128 [`quarkus.webauthn.login-page` defaults to `/login.html` — undocumented, causes 404 on protected routes](quarkus/GE-0128.md)
- GE-0133 [Quarkus CDI silently ignores `@ApplicationScoped` beans in jars without a Jandex index](quarkus/GE-0133.md)
- GE-0134 [`mvn install -DskipTests` runs Quarkus augmentation on library modules and fails if CDI is unsatisfied](quarkus/GE-0134.md)
- GE-0138 [`PanacheRepositoryBase.findById()` return type blocks SPI interface implementation](quarkus/GE-0138.md)
- GE-0142 [Hibernate `@OneToMany` collections must be initialized with `ArrayList`, not `CopyOnWriteArrayList`](quarkus/GE-0142.md)
- GE-0146 [Tyrus WebSocket client causes `ArC container not initialized` in `@QuarkusTest`](quarkus/GE-0146.md)
- GE-20260415-e5fa33 [Quarkiverse extension-descriptor rejects deployment pom that depends on X-deployment unless runtime pom depends on X](quarkus/GE-20260415-e5fa33.md)
- GE-20260415-53068a [RestAssured deserialises JSON floats as Float not Double — (Double) cast throws ClassCastException](quarkus/GE-20260415-53068a.md)
- GE-20260415-3ce5f3 [quarkus-junit (wrong) vs quarkus-junit5 (correct) — compiles silently, fails at test runtime](quarkus/GE-20260415-3ce5f3.md)
- GE-20260415-a13ed7 [A @Transactional JAX-RS method that calls @Transactional CDI beans sees their writes immediately — no flush needed](quarkus/GE-20260415-a13ed7.md)
- GE-20260415-748447 [Quarkiverse extension depending on a sibling quarkus-ledger library requires manual mvn install of that library first](quarkus/GE-20260415-748447.md)
- GE-20260415-884e48 [@Alternative @Priority(n) in CDI 4.0/Quarkus globally activates the alternative — causes AmbiguousResolutionException](quarkus/GE-20260415-884e48.md)
- GE-0148 [Quarkus JAX-RS resource without `@ApplicationScoped` silently breaks instance-level caches](quarkus/GE-0148.md)
- GE-0168 [Quarkus Flow discovers workflows from both YAML files and Java classes at build time](quarkus/GE-0168.md)
- GE-20260412-59ef31 [Quarkus WebSockets Next @OnOpen silently stops firing after hot-reload](quarkus/websockets-next.md)
- GE-20260412-2a0c4a [Quarkus REST client silently fails JSON deserialisation without quarkus-rest-client-reactive-jackson](quarkus/rest-client.md)
### scelight/
- GE-20260412-fec397 [Scelight tracker events: three API traps for player and unit identification](scelight/tracker-events.md)
### electron/
- GE-0173 [electron-builder `extraResources` strips the source directory name — packed path omits the subdir](electron/GE-0173.md)
- GE-0176 [Electron E2E tests silently fail in git worktrees — binary and runtime missing](electron/GE-0176.md)
- GE-0179 [Use an injectable `_pollFn` property to test Electron process managers without module mocking](electron/GE-0179.md)
### tools/
- GE-20260415-5aac89 [PixiJS 8: tile-rectangle top-left uses (VIEWPORT_H - y - 1) * SCALE — not the point formula](tools/GE-20260415-5aac89.md)
- GE-20260415-2af3bb [Assert derived values via the same source as the implementation — not hardcoded magic numbers](tools/GE-20260415-2af3bb.md)
- GE-20260415-0761e9 [Floating-point boundary check with == speed is fragile — use a smaller arrival threshold](tools/GE-20260415-0761e9.md)
- GE-0002 [Use git -C <path> to operate on a repo without cd-ing into it](tools/GE-0002.md)
- GE-0003 [Use a second Claude to verify the first Claude's work — and always confirm the absolute file path](tools/GE-0003.md)
- GE-0006 [Use `>?<` as a safe sed target for SVG text-element replacement in CI](tools/GE-0006.md)
- GE-0009 [Add a corruption signature check after text transformations that could silently garble content](tools/GE-0009.md)
- GE-0010 [Order dependent artifact creation by information flow, not by convention](tools/GE-0010.md)
- GE-0011 [Commit messages describe intent, not content — Claude can be confidently wrong about file state](tools/GE-0011.md)
- GE-0012 [Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state](tools/GE-0012.md)
- GE-0013 [Inject mandatory instructions directly into an existing session to override ignored guidelines](tools/GE-0013.md)
- GE-0169 [Assert on side effects, not LLM output, when testing AI tool use](tools/GE-0169.md)
- GE-0170 [Use real LLM invocations as protocol capture, replace with scripted replay for CI](tools/GE-0170.md)
- GE-0171 [Use claude `--mcp-config` + `--strict-mcp-config` to test MCP servers in isolation](tools/GE-0171.md)
- GE-0172 [`claude` CLI subprocess uses keychain OAuth — ANTHROPIC_API_KEY not required on dev machines](tools/GE-0172.md)
- GE-0015 [Browser cache hides a server fix — tests pass, user still sees the bug](tools/GE-0015.md)
- GE-20260415-ec4471 [Stacked PRs from a fork: push the base branch to upstream first](tools/GE-20260415-ec4471.md)
- GE-20260415-84faaf [Git branch naming conflict: can't create a branch whose name is a prefix of an existing branch path](tools/GE-20260415-84faaf.md)
- GE-0018 [Test encoding correctness at every pipeline layer with a shared garbling-signature helper](tools/GE-0018.md)
- GE-0019 [Generate realistic UI screenshots for blog posts using Playwright headless screenshots](tools/GE-0019.md)
- GE-0020 [Use `typora-root-url` in YAML front matter to make Jekyll root-relative image paths work in Typora](tools/GE-0020.md)
- GE-0021 [Queue debug commands as Runnables in the S2Agent for cross-thread execution in onStep()](tools/GE-0021.md)
- GE-0022 [Dual-runner scenario library: same named tests run against mock and real system](tools/GE-0022.md)
- GE-0025 [Use a stateful mock as a living specification that accumulates knowledge of the real system](tools/GE-0025.md)
- GE-0026 [ocraft `S2Coordinator` builder ends with `.launchStarcraft()` — there is no `.create()` terminal call](tools/GE-0026.md)
- GE-0027 [ocraft `agent.debug()` NPEs if called outside `onStep()` — debug interface only initialised during game loop](tools/GE-0027.md)
- GE-0028 [ocraft `DebugInterface` has no `debugSetMinerals(int)` — precise resource setting requires raw protobuf](tools/GE-0028.md)
- GE-0029 [ocraft unit observation returns `UnitInPool` wrapper with Optional fields — not plain `Unit` objects](tools/GE-0029.md)
- GE-0030 [ocraft `Units` enum uses full underscore separation for multi-word building names](tools/GE-0030.md)
- GE-0034 [Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus](tools/GE-0034.md)
- GE-0035 [Trigger exhaustive sweeps by activity count, not time, to match cost to actual need](tools/GE-0035.md)
- GE-0039 [Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other](tools/GE-0039.md)
- GE-0040 [Use `waitpid(WNOHANG)` polling to verify signal delivery in subprocess tests](tools/GE-0040.md)
- GE-0042 [Python `format(?:ting|ted|s)?` matches "formats" (plural noun) — false positive in text classifiers](tools/GE-0042.md)
- GE-0043 [Use conventional commit scope as the primary feature-clustering signal over file paths](tools/GE-0043.md)
- GE-0044 [MADR `Date:` field is never auto-populated — always empty unless manually set](tools/GE-0044.md)
- GE-0048 [Large Bash tool output is saved to a temp file — `cat` on that path loops; use Read tool](tools/GE-0048.md)
- GE-0049 [Create and close GitHub issues in bulk with a bash function and URL number extraction](tools/GE-0049.md)
- GE-0050 [Use conventional commit scope to cluster commits into issues without reading per-commit diffs](tools/GE-0050.md)
- GE-0054 [Demand-load reference material in Claude Code skills via separate .md files](tools/GE-0054.md)
- GE-0055 [Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers](tools/GE-0055.md)
- GE-0074 [tmux resize-pane Silently No-ops for Detached Sessions](tools/GE-0074.md)
- GE-0075 [tmux capture-pane Output Ends with \n — split() Gives paneHeight+1 Elements](tools/GE-0075.md)
- GE-0082 [html2text strips trailing whitespace inside bold/italic markers via internal `stressed` flag](tools/GE-0082.md)
- GE-0083 [BeautifulSoup `prettify()` silently discards trailing whitespace from inline element text nodes](tools/GE-0083.md)
- GE-0084 [Headless Playwright does not cache iframe responses the way real browsers do — content assertions give false passes](tools/GE-0084.md)
- GE-0085 [Two `sync_playwright()` context managers in the same pytest session conflict with asyncio](tools/GE-0085.md)
- GE-0086 [Regex matching social platform names silently strips content paragraphs that mention those platforms as topics](tools/GE-0086.md)
- GE-0087 [Assert that `iframe.src` changes after a save, not that the iframe content changed](tools/GE-0087.md)
- GE-0088 [Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text](tools/GE-0088.md)
- GE-0089 [Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()`](tools/GE-0089.md)
- GE-0090 [html2text `stressed` flag: causes `data.strip()` on first text node inside bold/italic — not documented anywhere](tools/GE-0090.md)
- GE-0091 [validate_document.py flags markdown tables inside fenced code blocks as corrupted](tools/GE-0091.md)
- GE-0092 [Use `.locator().all()` not `.locator().nth(n)` when screenshotting multiple elements of the same class](tools/GE-0092.md)
- GE-0096 [send-keys silently interprets "Enter"/"Escape" as key names without -l flag](tools/GE-0096.md)
- GE-0097 [send-keys key name lookup is per-argument, not per-word within an argument](tools/GE-0097.md)
- GE-0098 [capture-pane pads every output line to full pane width — blank lines are grid artifacts](tools/GE-0098.md)
- GE-0099 [attach-session fails from ProcessBuilder — requires a real PTY](tools/GE-0099.md)
- GE-0100 [TUI apps render garbled on WebSocket connect — tmux pane dimensions not synced to browser viewport](tools/GE-0100.md)
- GE-0101 [`page.evaluate()` does not await async JavaScript functions](tools/GE-0101.md)
- GE-0102 [`to_be_visible()` fails on elements inside collapsed parent containers](tools/GE-0102.md)
- GE-0103 [`wait_for_selector(':not(.open)')` waits for visible, but the closed modal is `display:none`](tools/GE-0103.md)
- GE-0106 [SVG textPath `dy` attribute does not reliably position text below a circular arc line](tools/GE-0106.md)
- GE-0107 [Partial Heading Match in `str.replace()` Corrupts Markdown Headings When Heading Has a Suffix](tools/GE-0107.md)
- GE-0108 [Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown](tools/GE-0108.md)
- GE-0113 [`gh auth refresh` Requires an Interactive Terminal — the `!` Prefix in Claude Code Won't Complete the OAuth Flow](tools/GE-0113.md)
- GE-0114 [`href="dir/"` serves `index.html` on a web server but opens a directory listing locally](tools/GE-0114.md)
- GE-0115 [`maven-compiler-plugin` `<excludes>` Doesn't Prevent Transitive Compilation](tools/GE-0115.md)
- GE-0118 [`git restore --staged .` Also Reverts Working Tree Changes](tools/GE-0118.md)
- GE-0127 [Use `terminal.paste()` not `ws.send()` to inject text into an xterm.js terminal from JavaScript](tools/GE-0127.md)
- GE-0129 [iframe swallows mousemove events when the cursor enters it during a drag](tools/GE-0129.md)
- GE-0130 [`JSON.stringify()` in HTML onclick attribute silently truncates at the first inner double-quote](tools/GE-0130.md)
- GE-0132 [Walk text character-by-character tracking quote state to skip keyword matching inside strings](tools/GE-0132.md)
- GE-0135 [Return resolved data instead of calling a complex interface directly — eliminates mocking even with 12+ overloads](tools/GE-0135.md)
- GE-0136 [Structured text validators produce false positives from markers inside fenced code blocks](tools/GE-0136.md)
- GE-0137 [`git push` to a non-bare repo is rejected when the target branch is checked out](tools/GE-0137.md)
- GE-0140 [`git filter-branch --msg-filter` doubles footers already in commit bodies — two-pass required](tools/GE-0140.md)
- GE-0141 [Use `$GIT_COMMIT` in `--msg-filter` to selectively rewrite only specific commits by hash](tools/GE-0141.md)
- GE-0145 [Playwright Java: `waitForFunction(String, WaitForFunctionOptions)` silently serialises options as JS arg](tools/GE-0145.md)
- GE-0147 [Java 11 WebSocket: `ws.request(N)` must be called before `onText` fires](tools/GE-0147.md)
- GE-0149 [Maven Surefire: profile `<excludedGroups/>` doesn't clear base config — use `combine.self="override"`](tools/GE-0149.md)
- GE-0150 [Expose `window.__test` semantic API for robust canvas/WebGL test assertions](tools/GE-0150.md)
- GE-0151 [Prove WebSocket end-to-end connectivity by waiting for first message, not just `onOpen`](tools/GE-0151.md)
- GE-0152 [PixiJS 8: Graphics mask added as child of anchored Sprite makes Sprite invisible](tools/GE-0152.md)
- GE-0153 [CSS `var()` in an iframe `<style>` tag silently produces no output](tools/GE-0153.md)
- GE-0154 [Replacing a CSS rule block silently deletes adjacent rules not included in the replacement](tools/GE-0154.md)
- GE-0155 [SVG `fill=""` presentation attributes don't reliably resolve CSS custom properties](tools/GE-0155.md)
- GE-0156 [macOS `sed -i ''` silently empties a file when the pattern contains `**` (double asterisk)](tools/GE-0156.md)
- GE-0121 [`mv` Project Folder Invalidates Bash Tool's Shell cwd Mid-Session](tools/GE-0121.md)
- GE-0124 [Renaming a Claude Code Project Directory Leaves Stale Absolute Paths in `.claude/settings.local.json`](tools/GE-0124.md)
- GE-0157 [macOS tmp filesystem full silently blocks all Claude Code Bash tool commands](tools/GE-0157.md)
- GE-0159 [Gitignored CLAUDE.md symlink for consistent AI workspace config across entry points](tools/GE-0159.md)
- GE-0161 [`gh project item-edit --field-id` rejects field names — requires internal GraphQL node ID](tools/GE-0161.md)
- GE-0162 [Gradle 8.6 fails cryptically when JAVA_HOME points to Java 26](tools/GE-0162.md)
- GE-0166 [Dispatch parallel agents for exhaustive cross-codebase comparison](tools/GE-0166.md)
- GE-0174 [`git filter-branch` fails with staged changes — even for message-only rewrites](tools/GE-0174.md)
- GE-0175 [Merging a branch with `--delete-branch` auto-closes any PR targeting that branch](tools/GE-0175.md)
- GE-0177 [Python `HTTPServer('localhost', port)` may bind to IPv6 on macOS 14+ — health checks on 127.0.0.1 then fail](tools/GE-0177.md)
- GE-0178 [Use `git filter-branch --msg-filter` with a Python hash→refs mapping to bulk-add commit footers](tools/GE-0178.md)
- GE-0180 [`jest.useFakeTimers()` also fakes `setImmediate` — mock process exit events hang](tools/GE-0180.md)
- GE-20260410-5fd0c3 [`validate_garden.py` strip_code_fences regex silently hides all IDs after a literal triple backtick in entry body text](tools/hortora.md)
- GE-20260412-17c8ce [Enable GitHub Pages Actions source and fix branch protection via gh API — no browser](tools/GE-20260412-17c8ce.md)
- GE-20260412-e4773d [Python regex alternation matches leftmost option — longer pattern must come before any pattern that is a prefix of it](tools/GE-20260412-e4773d.md)
- GE-20260412-b6c0f8 [Claude Code Read tool fails on files over ~256KB — use offset/limit or Bash grep](tools/GE-20260412-b6c0f8.md)

---

## By Symptom / Type

*(requires type metadata per entry — to be built in a dedicated harvest session)*

---

## By Label

### #algorithm
- GE-0034 [Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus](tools/GE-0034.md)
- GE-0035 [Trigger exhaustive sweeps by activity count, not time, to match cost to actual need](tools/GE-0035.md)
### #analysis
- GE-0043 [Use conventional commit scope as the primary feature-clustering signal over file paths](tools/GE-0043.md)
### #appkit
- GE-0073 [NSEvent local monitor + BOOL flag for mode-based key interception](macos-native-appkit/GE-0073.md)
### #automation
- GE-0049 [Create and close GitHub issues in bulk with a bash function and URL number extraction](tools/GE-0049.md)
- GE-0050 [Use conventional commit scope to cluster commits into issues without reading per-commit diffs](tools/GE-0050.md)
- GE-0092 [Use `.locator().all()` not `.locator().nth(n)` when screenshotting multiple elements of the same class](tools/GE-0092.md)
### #beautifulsoup
- GE-0088 [Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text](tools/GE-0088.md)
- GE-0089 [Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()`](tools/GE-0089.md)
### #blogging
- GE-0019 [Generate realistic UI screenshots for blog posts using Playwright headless screenshots](tools/GE-0019.md)
- GE-0020 [Use `typora-root-url` in YAML front matter to make Jekyll root-relative image paths work in Typora](tools/GE-0020.md)
- GE-0108 [Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown](tools/GE-0108.md)
### #browser-caching
- GE-0087 [Assert that `iframe.src` changes after a save, not that the iframe content changed](tools/GE-0087.md)
### #ci-cd
- GE-0006 [Use `>?<` as a safe sed target for SVG text-element replacement in CI](tools/GE-0006.md)
- GE-0039 [Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other](tools/GE-0039.md)
- GE-0178 [Use `git filter-branch --msg-filter` with a Python hash→refs mapping to bulk-add commit footers](tools/GE-0178.md)
- GE-20260412-17c8ce [Enable GitHub Pages Actions source and fix branch protection via gh API — no browser](tools/GE-20260412-17c8ce.md)
### #claude-cli
- GE-0019 [Generate realistic UI screenshots for blog posts using Playwright headless screenshots](tools/GE-0019.md)
- GE-0171 [Use claude `--mcp-config` + `--strict-mcp-config` to test MCP servers in isolation](tools/GE-0171.md)
- GE-0172 [`claude` CLI subprocess uses keychain OAuth — ANTHROPIC_API_KEY not required on dev machines](tools/GE-0172.md)
### #claude-code
- GE-0013 [Inject mandatory instructions directly into an existing session to override ignored guidelines](tools/GE-0013.md)
- GE-0054 [Demand-load reference material in Claude Code skills via separate .md files](tools/GE-0054.md)
- GE-0055 [Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers](tools/GE-0055.md)
- GE-0159 [Gitignored CLAUDE.md symlink for consistent AI workspace config across entry points](tools/GE-0159.md)
### #context
- GE-0013 [Inject mandatory instructions directly into an existing session to override ignored guidelines](tools/GE-0013.md)
### #debugging
- GE-0047 [Use javap to find the actual Quarkus config property name from a field annotation](quarkus/GE-0047.md)
### #deduplication
- GE-0034 [Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus](tools/GE-0034.md)
### #defensive
- GE-0009 [Add a corruption signature check after text transformations that could silently garble content](tools/GE-0009.md)
- GE-0018 [Test encoding correctness at every pipeline layer with a shared garbling-signature helper](tools/GE-0018.md)
### #documentation
- GE-0108 [Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown](tools/GE-0108.md)
### #drools
- GE-0123 [Use Java-Managed Event Buffers + Fresh RuleUnitInstance per Tick Instead of Drools Fusion STREAM Mode for Temporal CEP in Quarkus Rule Units](quarkus/GE-0123.md)
### #git
- GE-0002 [Use git -C <path> to operate on a repo without cd-ing into it](tools/GE-0002.md)
- GE-0043 [Use conventional commit scope as the primary feature-clustering signal over file paths](tools/GE-0043.md)
- GE-0141 [Use `$GIT_COMMIT` in `--msg-filter` to selectively rewrite only specific commits by hash](tools/GE-0141.md)
- GE-0178 [Use `git filter-branch --msg-filter` with a Python hash→refs mapping to bulk-add commit footers](tools/GE-0178.md)
### #github
- GE-0049 [Create and close GitHub issues in bulk with a bash function and URL number extraction](tools/GE-0049.md)
- GE-20260412-17c8ce [Enable GitHub Pages Actions source and fix branch protection via gh API — no browser](tools/GE-20260412-17c8ce.md)
### #history-rewriting
- GE-0141 [Use `$GIT_COMMIT` in `--msg-filter` to selectively rewrite only specific commits by hash](tools/GE-0141.md)
### #html2text
- GE-0088 [Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text](tools/GE-0088.md)
### #integration
- GE-0071 [Bridge SmallRye in-memory channel to Quarkus Flow using @Incoming + startInstance()](quarkus/GE-0071.md)
### #intellij
- GE-0119 [PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated](intellij-platform/GE-0119.md)
### #java
- GE-0077 [Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean](quarkus/GE-0077.md)
- GE-0158 [Use `mvn compile` to enumerate all call sites when changing a Java record signature](java/GE-0158.md)
### #java-dsl
- GE-0004 [Use typed element return in generator/predicate pairs to enforce cross-API type agreement](java/GE-0004.md)
- GE-20260412-e51f12 [Varargs type-capture for type-safe DSL methods with full generic support](approaches/java-dsl-design.md)
### #lambda
- GE-0037 [Inject a Supplier<Instant> to test time-dependent logic without sleeping or mocking frameworks](java/GE-0037.md)
### #llm-testing
- GE-0003 [Use a second Claude to verify the first Claude's work — and always confirm the absolute file path](tools/GE-0003.md)
- GE-0012 [Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state](tools/GE-0012.md)
- GE-0169 [Assert on side effects, not LLM output, when testing AI tool use](tools/GE-0169.md)
- GE-0170 [Use real LLM invocations as protocol capture, replace with scripted replay for CI](tools/GE-0170.md)
- GE-0171 [Use claude `--mcp-config` + `--strict-mcp-config` to test MCP servers in isolation](tools/GE-0171.md)
- GE-0172 [`claude` CLI subprocess uses keychain OAuth — ANTHROPIC_API_KEY not required on dev machines](tools/GE-0172.md)
### #macos-native
- GE-0051 [Smoke-test WKWebView rendering by checking for a new WebContent process](macos-native-appkit/GE-0051.md)
### #markdown
- GE-0108 [Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown](tools/GE-0108.md)
### #multi-agent
- GE-0003 [Use a second Claude to verify the first Claude's work — and always confirm the absolute file path](tools/GE-0003.md)
- GE-0012 [Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state](tools/GE-0012.md)
### #multi-repo
- GE-0002 [Use git -C <path> to operate on a repo without cd-ing into it](tools/GE-0002.md)
### #panama-ffm
- GE-0039 [Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other](tools/GE-0039.md)
### #parsing
- GE-0132 [Walk text character-by-character tracking quote state to skip keyword matching inside strings](tools/GE-0132.md)
### #pattern
- GE-0021 [Queue debug commands as Runnables in the S2Agent for cross-thread execution in onStep()](tools/GE-0021.md)
- GE-0179 [Use an injectable `_pollFn` property to test Electron process managers without module mocking](electron/GE-0179.md)
- GE-0040 [Use `waitpid(WNOHANG)` polling to verify signal delivery in subprocess tests](tools/GE-0040.md)
- GE-0071 [Bridge SmallRye in-memory channel to Quarkus Flow using @Incoming + startInstance()](quarkus/GE-0071.md)
- GE-0073 [NSEvent local monitor + BOOL flag for mode-based key interception](macos-native-appkit/GE-0073.md)
- GE-0077 [Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean](quarkus/GE-0077.md)
- GE-0089 [Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()`](tools/GE-0089.md)
- GE-0095 [Use a dedicated @QuarkusTest class with @InjectMock to isolate side-effectful endpoint tests](quarkus/GE-0095.md)
- GE-0105 [Drools as Action Compiler for GOAP — One Session per Tick, Not per A* Node](drools/GE-0105.md)
- GE-0119 [PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated](intellij-platform/GE-0119.md)
- GE-0123 [Use Java-Managed Event Buffers + Fresh RuleUnitInstance per Tick Instead of Drools Fusion STREAM Mode for Temporal CEP in Quarkus Rule Units](quarkus/GE-0123.md)
- GE-0127 [Use `terminal.paste()` not `ws.send()` to inject text into an xterm.js terminal from JavaScript](tools/GE-0127.md)
- GE-0132 [Walk text character-by-character tracking quote state to skip keyword matching inside strings](tools/GE-0132.md)
- GE-0135 [Return resolved data instead of calling a complex interface directly — eliminates mocking even with 12+ overloads](tools/GE-0135.md)
### #performance
- GE-0054 [Demand-load reference material in Claude Code skills via separate .md files](tools/GE-0054.md)
- GE-0105 [Drools as Action Compiler for GOAP — One Session per Tick, Not per A* Node](drools/GE-0105.md)
### #playwright
- GE-0087 [Assert that `iframe.src` changes after a save, not that the iframe content changed](tools/GE-0087.md)
### #preprocessing
- GE-0088 [Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text](tools/GE-0088.md)
### #prettify
- GE-0089 [Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()`](tools/GE-0089.md)
### #quarkus
- GE-0033 [Use `@UnlessBuildProfile("prod")` to strip debug/QA beans from production at CDI level](quarkus/GE-0033.md)
- GE-0047 [Use javap to find the actual Quarkus config property name from a field annotation](quarkus/GE-0047.md)
- GE-0077 [Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean](quarkus/GE-0077.md)
### #security
- GE-0033 [Use `@UnlessBuildProfile("prod")` to strip debug/QA beans from production at CDI level](quarkus/GE-0033.md)
### #agentic
- GE-0166 [Dispatch parallel agents for exhaustive cross-codebase comparison](tools/GE-0166.md)
### #architecture
- GE-0166 [Dispatch parallel agents for exhaustive cross-codebase comparison](tools/GE-0166.md)
### #strategy
- GE-0003 [Use a second Claude to verify the first Claude's work — and always confirm the absolute file path](tools/GE-0003.md)
- GE-0009 [Add a corruption signature check after text transformations that could silently garble content](tools/GE-0009.md)
- GE-0010 [Order dependent artifact creation by information flow, not by convention](tools/GE-0010.md)
- GE-0012 [Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state](tools/GE-0012.md)
- GE-0018 [Test encoding correctness at every pipeline layer with a shared garbling-signature helper](tools/GE-0018.md)
- GE-0022 [Dual-runner scenario library: same named tests run against mock and real system](tools/GE-0022.md)
- GE-0025 [Use a stateful mock as a living specification that accumulates knowledge of the real system](tools/GE-0025.md)
- GE-0034 [Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus](tools/GE-0034.md)
- GE-0035 [Trigger exhaustive sweeps by activity count, not time, to match cost to actual need](tools/GE-0035.md)
- GE-0043 [Use conventional commit scope as the primary feature-clustering signal over file paths](tools/GE-0043.md)
- GE-0050 [Use conventional commit scope to cluster commits into issues without reading per-commit diffs](tools/GE-0050.md)
- GE-0105 [Drools as Action Compiler for GOAP — One Session per Tick, Not per A* Node](drools/GE-0105.md)
- GE-0150 [Expose `window.__test` semantic API for robust canvas/WebGL test assertions](tools/GE-0150.md)
- GE-0151 [Prove WebSocket end-to-end connectivity by waiting for first message, not just `onOpen`](tools/GE-0151.md)
- GE-0166 [Dispatch parallel agents for exhaustive cross-codebase comparison](tools/GE-0166.md)
- GE-0169 [Assert on side effects, not LLM output, when testing AI tool use](tools/GE-0169.md)
- GE-0170 [Use real LLM invocations as protocol capture, replace with scripted replay for CI](tools/GE-0170.md)
### #svg
- GE-0006 [Use `>?<` as a safe sed target for SVG text-element replacement in CI](tools/GE-0006.md)
### #technique
- GE-0019 [Generate realistic UI screenshots for blog posts using Playwright headless screenshots](tools/GE-0019.md)
### #testing
- GE-0018 [Test encoding correctness at every pipeline layer with a shared garbling-signature helper](tools/GE-0018.md)
- GE-0179 [Use an injectable `_pollFn` property to test Electron process managers without module mocking](electron/GE-0179.md)
- GE-0021 [Queue debug commands as Runnables in the S2Agent for cross-thread execution in onStep()](tools/GE-0021.md)
- GE-0022 [Dual-runner scenario library: same named tests run against mock and real system](tools/GE-0022.md)
- GE-0025 [Use a stateful mock as a living specification that accumulates knowledge of the real system](tools/GE-0025.md)
- GE-0037 [Inject a Supplier<Instant> to test time-dependent logic without sleeping or mocking frameworks](java/GE-0037.md)
- GE-0039 [Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other](tools/GE-0039.md)
- GE-0040 [Use `waitpid(WNOHANG)` polling to verify signal delivery in subprocess tests](tools/GE-0040.md)
- GE-0051 [Smoke-test WKWebView rendering by checking for a new WebContent process](macos-native-appkit/GE-0051.md)
- GE-0061 [Use tput to verify PTY window dimensions in JVM-mode Panama FFM tests](java-panama-ffm/GE-0061.md)
- GE-0087 [Assert that `iframe.src` changes after a save, not that the iframe content changed](tools/GE-0087.md)
- GE-0092 [Use `.locator().all()` not `.locator().nth(n)` when screenshotting multiple elements of the same class](tools/GE-0092.md)
- GE-0095 [Use a dedicated @QuarkusTest class with @InjectMock to isolate side-effectful endpoint tests](quarkus/GE-0095.md)
- GE-0119 [PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated](intellij-platform/GE-0119.md)
- GE-0127 [Use `terminal.paste()` not `ws.send()` to inject text into an xterm.js terminal from JavaScript](tools/GE-0127.md)
- GE-0135 [Return resolved data instead of calling a complex interface directly — eliminates mocking even with 12+ overloads](tools/GE-0135.md)
- GE-0150 [Expose `window.__test` semantic API for robust canvas/WebGL test assertions](tools/GE-0150.md)
- GE-0151 [Prove WebSocket end-to-end connectivity by waiting for first message, not just `onOpen`](tools/GE-0151.md)
- GE-0169 [Assert on side effects, not LLM output, when testing AI tool use](tools/GE-0169.md)
- GE-0170 [Use real LLM invocations as protocol capture, replace with scripted replay for CI](tools/GE-0170.md)
- GE-0171 [Use claude `--mcp-config` + `--strict-mcp-config` to test MCP servers in isolation](tools/GE-0171.md)
### #token-budget
- GE-0054 [Demand-load reference material in Claude Code skills via separate .md files](tools/GE-0054.md)
- GE-0055 [Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers](tools/GE-0055.md)
### #tooling
- GE-0020 [Use `typora-root-url` in YAML front matter to make Jekyll root-relative image paths work in Typora](tools/GE-0020.md)
### #trigger-hygiene
- GE-0055 [Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers](tools/GE-0055.md)
### #workaround
- GE-0061 [Use tput to verify PTY window dimensions in JVM-mode Panama FFM tests](java-panama-ffm/GE-0061.md)
### #refactoring
- GE-0158 [Use `mvn compile` to enumerate all call sites when changing a Java record signature](java/GE-0158.md)
### #workflow
- GE-0010 [Order dependent artifact creation by information flow, not by convention](tools/GE-0010.md)
- GE-0013 [Inject mandatory instructions directly into an existing session to override ignored guidelines](tools/GE-0013.md)
- GE-0035 [Trigger exhaustive sweeps by activity count, not time, to match cost to actual need](tools/GE-0035.md)
- GE-0159 [Gitignored CLAUDE.md symlink for consistent AI workspace config across entry points](tools/GE-0159.md)

## Tag Index

agentic, algorithm, analysis, appkit, architecture, automation, beautifulsoup, blogging, browser-caching, ci-cd, claude-cli, claude-code, context, debugging, deduplication, defensive, documentation, drools, git, github, history-rewriting, html2text, integration, intellij, java, java-dsl, lambda, llm-testing, macos-native, markdown, mcp-server, multi-agent, multi-repo, panama-ffm, parsing, pattern, performance, playwright, preprocessing, prettify, quarkus, refactoring, security, strategy, svg, technique, testing, token-budget, tooling, trigger-hygiene, workaround, workflow
