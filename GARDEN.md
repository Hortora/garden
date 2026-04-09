**Last assigned ID:** GE-0144
**Last full DEDUPE sweep:** 2026-04-09
**Entries merged since last sweep:** 0
**Drift threshold:** 10

## By Technology

### beautifulsoup/
- GE-0008 [BeautifulSoup lxml parser double-encodes non-ASCII when input str contains `<meta charset>`](beautifulsoup/encoding.md)
- GE-0016 [Hardcoded path traversal fails silently when scanning file copies in an alternate directory](beautifulsoup/encoding.md)
- GE-0017 [`html.parser` does not add `<body>` wrapper to fragments; `.body.next` returns None](beautifulsoup/encoding.md)
### claude-code/
- GE-0001 [Claude Code settings.json rejects unknown top-level fields despite additionalProperties schema](claude-code/settings-json-quirks.md)
### drools/
- GE-0056 [Drools 10 Rule Units DRL: three silent syntax traps with Java records and OOPath patterns](drools/quarkus-testing.md)
- GE-0057 [`addParamsFact()` must be called at build time — silent wrong-fact extraction at runtime](drools/rule-builder-dsl.md)
- GE-0063 [`DataSource.createStore()` fails with NullPointerException in plain JUnit when using `drools-quarkus`](drools/quarkus-testing.md)
- GE-0105 [Drools as Action Compiler for GOAP — One Session per Tick, Not per A* Node](drools/drools-goap-planning.md)
- GE-0109 [Phase 2 Rules Silently Don't Fire When Depending on List Mutated by Phase 1](drools/drools-rule-units.md)
### intellij-platform/
- GE-0079 [PostprocessReformattingAspect Adds Spurious Space in Annotation Attributes After PSI Write](intellij-platform/rename-refactoring.md)
- GE-0080 [renamePsiElementProcessor Requires order="first" for getPostRenameCallback to Fire](intellij-platform/rename-refactoring.md)
- GE-0081 [Raw PsiElement References Collected in prepareRenaming() Are Invalidated by the Rename Write Action](intellij-platform/rename-refactoring.md)
- GE-0093 [FQN Resolution Inside FileBasedIndexExtension Causes Recursive Index Read and Crash](intellij-platform/indexing.md)
- GE-0110 [`localInspection` in plugin.xml Requires `implementationClass` and Explicit `shortName`](intellij-platform/inspections.md)
- GE-0111 [`intellij-platform-gradle-plugin` 2.x Auto-Sets `untilBuild` to `sinceBuild.*`, Blocking Newer IDEs](intellij-platform/gradle-build.md)
- GE-0112 [`SafeDeleteProcessorDelegate.shouldDeleteElement()` Removed in 2023.2 — Use `findConflicts()`](intellij-platform/refactoring.md)
- GE-0116 [Custom `FileBasedIndexExtension` Not Populated After `addFileToProject()` in `BasePlatformTestCase`](intellij-platform/plugin-testing.md)
- GE-0117 [`RenameHandler` Intercepts Before `RenamePsiElementProcessor.substituteElementToRename()` Is Called](intellij-platform/rename-refactoring.md)
- GE-0119 [PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated](intellij-platform/plugin-testing.md)
- GE-0120 [`FindUsagesManager` Has a Public Constructor and Accepts `FindUsagesHandlerBase` Directly](intellij-platform/find-usages.md)
### java/
- GE-0004 [Use typed element return in generator/predicate pairs to enforce cross-API type agreement](java/generics.md)
- GE-0023 [Java records with `List<T>` fields are not truly immutable without a compact constructor](java/records.md)
- GE-0024 [Multiple `volatile` fields read without synchronisation produce torn cross-field snapshots](java/concurrency.md)
- GE-0037 [Inject a Supplier<Instant> to test time-dependent logic without sleeping or mocking frameworks](java/clock-testing.md)
- GE-0058 [Wrong generic type parameters in Java stub methods compile silently](java/generics-gotchas.md)
- GE-0064 [Maven aggregator pom requires `<packaging>pom</packaging>` — omitting it causes a cryptic build failure](java/maven.md)
- GE-0067 [Maven ignores non-Java files in `src/main/java/` — resources must be in `src/main/resources/` or explicitly declared](java/maven.md)
- GE-0122 [`package-private` Members in `a.b.c` Are Inaccessible from `a.b` — Sub-Packages Are Distinct Packages](java/package-access.md)
### java-panama-ffm/
- GE-0038 [Panama FFM native write/read on PTY slave fds causes SIGTRAP JVM crash in the next test class (macOS AArch64)](java-panama-ffm/pty-patterns.md)
- GE-0053 [Panama FFM `IOC_OUT` ioctl returns success but leaves buffer zeroed (macOS AArch64, JVM mode)](java-panama-ffm/pty-patterns.md)
- GE-0060 [tput silently reports 0 when TERM env var is absent in PTY integration tests](java-panama-ffm/pty-patterns.md)
- GE-0061 [Use tput to verify PTY window dimensions in JVM-mode Panama FFM tests](java-panama-ffm/pty-patterns.md)
### macos-native-appkit/
- GE-0051 [Smoke-test WKWebView rendering by checking for a new WebContent process](macos-native-appkit/appkit-panama-ffm.md)
- GE-0072 [`performSelectorOnMainThread:waitUntilDone:NO` from main thread schedules asynchronously](macos-native-appkit/appkit-panama-ffm.md)
- GE-0073 [NSEvent local monitor + BOOL flag for mode-based key interception](macos-native-appkit/appkit-panama-ffm.md)
### permuplate/
- GE-0005 [@PermuteReturn methods with hand-written return types silently disappear via boundary omission](permuplate/permuplate-templates.md)
- GE-0007 [typeArgList(from, to, style) accepts dynamic JEXL expressions for from/to, not just constants](permuplate/permuplate-templates.md)
### quarkus/
- GE-0031 [`<packaging>quarkus</packaging>` in pom.xml is non-standard and causes tooling issues — Quarkus doesn't generate it](quarkus/maven.md)
- GE-0032 [Quarkus `@Scheduled` allows overlapping executions by default — no warning, just a race](quarkus/scheduler.md)
- GE-0033 [Use `@UnlessBuildProfile("prod")` to strip debug/QA beans from production at CDI level](quarkus/cdi.md)
- GE-0036 [@ApplicationScoped bean state accumulates across @QuarkusTest classes in the same run](quarkus/testing.md)
- GE-0045 [Quarkus WebAuthn config keys use wrong names — silently ignored, no warning](quarkus/webauthn.md)
- GE-0046 [WebAuthn session cookie encryption key is `quarkus.http.auth.session.encryption-key` — not documented in WebAuthn extension docs](quarkus/webauthn.md)
- GE-0047 [Use javap to find the actual Quarkus config property name from a field annotation](quarkus/config.md)
- GE-0052 [`@UnlessBuildProfile` has undocumented `anyOf` attribute for multi-profile exclusion](quarkus/profiles.md)
- GE-0062 [`HttpAuthenticationMechanism` injections resolve before `@Observes StartupEvent` fires](quarkus/cdi.md)
- GE-0065 [Quarkus `quarkus:dev` silently skips and returns BUILD SUCCESS if the `build` goal is missing from plugin executions](quarkus/maven.md)
- GE-0066 [`@UnlessBuildProfile` on a bean causes "Unsatisfied dependency" in any bean that injects it without a matching profile guard](quarkus/cdi.md)
- GE-0068 [Quarkus Flow `consume` steps re-deserialize input — mutable mutations don't propagate](quarkus/quarkus-flow.md)
- GE-0069 [Quarkus Flow: plain mutable POJO as workflow input → `FAIL_ON_EMPTY_BEANS` at runtime](quarkus/quarkus-flow.md)
- GE-0070 [Quarkus Flow `listen` task does not receive from SmallRye in-memory channels](quarkus/quarkus-flow.md)
- GE-0071 [Bridge SmallRye in-memory channel to Quarkus Flow using @Incoming + startInstance()](quarkus/quarkus-flow.md)
- GE-0076 [-D Flags After -jar Don't Override Config Expressions in Quarkus](quarkus/config.md)
- GE-0077 [Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean](quarkus/webauthn.md)
- GE-0078 [Quarkus WebAuthn Actual HTTP Endpoint Paths (Only Discoverable via Bytecode)](quarkus/webauthn.md)
- GE-0094 [@QuarkusTest HTTP endpoint tests fire real @ApplicationScoped beans — including side-effectful adapters](quarkus/testing.md)
- GE-0095 [Use a dedicated @QuarkusTest class with @InjectMock to isolate side-effectful endpoint tests](quarkus/testing.md)
- GE-0104 [Authenticator.publicKeyAlgorithm has no getter/setter — field cannot be persisted in WebAuthnUserProvider](quarkus/webauthn.md)
- GE-0123 [Use Java-Managed Event Buffers + Fresh RuleUnitInstance per Tick Instead of Drools Fusion STREAM Mode for Temporal CEP in Quarkus Rule Units](quarkus/drools-rule-units.md)
### tools/
- GE-0002 [Use git -C <path> to operate on a repo without cd-ing into it](tools/git.md)
- GE-0003 [Use a second Claude to verify the first Claude's work — and always confirm the absolute file path](tools/llm-testing.md)
- GE-0006 [Use `>?<` as a safe sed target for SVG text-element replacement in CI](tools/ci-cd.md)
- GE-0009 [Add a corruption signature check after text transformations that could silently garble content](tools/defensive-programming.md)
- GE-0010 [Order dependent artifact creation by information flow, not by convention](tools/workflow.md)
- GE-0011 [Commit messages describe intent, not content — Claude can be confidently wrong about file state](tools/llm-testing.md)
- GE-0012 [Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state](tools/llm-testing.md)
- GE-0013 [Inject mandatory instructions directly into an existing session to override ignored guidelines](tools/claude-code.md)
- GE-0015 [Browser cache hides a server fix — tests pass, user still sees the bug](tools/browser-testing.md)
- GE-0018 [Test encoding correctness at every pipeline layer with a shared garbling-signature helper](tools/defensive-programming.md)
- GE-0019 [Generate realistic UI screenshots for blog posts using Playwright headless screenshots](tools/playwright.md)
- GE-0020 [Use `typora-root-url` in YAML front matter to make Jekyll root-relative image paths work in Typora](tools/typora.md)
- GE-0021 [Queue debug commands as Runnables in the S2Agent for cross-thread execution in onStep()](tools/ocraft-s2client.md)
- GE-0022 [Dual-runner scenario library: same named tests run against mock and real system](tools/testing-patterns.md)
- GE-0025 [Use a stateful mock as a living specification that accumulates knowledge of the real system](tools/testing-patterns.md)
- GE-0026 [ocraft `S2Coordinator` builder ends with `.launchStarcraft()` — there is no `.create()` terminal call](tools/ocraft-s2client.md)
- GE-0027 [ocraft `agent.debug()` NPEs if called outside `onStep()` — debug interface only initialised during game loop](tools/ocraft-s2client.md)
- GE-0028 [ocraft `DebugInterface` has no `debugSetMinerals(int)` — precise resource setting requires raw protobuf](tools/ocraft-s2client.md)
- GE-0029 [ocraft unit observation returns `UnitInPool` wrapper with Optional fields — not plain `Unit` objects](tools/ocraft-s2client.md)
- GE-0030 [ocraft `Units` enum uses full underscore separation for multi-word building names](tools/ocraft-s2client.md)
- GE-0034 [Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus](tools/data-structures.md)
- GE-0035 [Trigger exhaustive sweeps by activity count, not time, to match cost to actual need](tools/data-structures.md)
- GE-0039 [Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other](tools/maven.md)
- GE-0040 [Use `waitpid(WNOHANG)` polling to verify signal delivery in subprocess tests](tools/testing-patterns.md)
- GE-0042 [Python `format(?:ting|ted|s)?` matches "formats" (plural noun) — false positive in text classifiers](tools/regex.md)
- GE-0043 [Use conventional commit scope as the primary feature-clustering signal over file paths](tools/git.md)
- GE-0044 [MADR `Date:` field is never auto-populated — always empty unless manually set](tools/adr.md)
- GE-0048 [Large Bash tool output is saved to a temp file — `cat` on that path loops; use Read tool](tools/claude-code.md)
- GE-0049 [Create and close GitHub issues in bulk with a bash function and URL number extraction](tools/github-cli.md)
- GE-0050 [Use conventional commit scope to cluster commits into issues without reading per-commit diffs](tools/git.md)
- GE-0054 [Demand-load reference material in Claude Code skills via separate .md files](tools/claude-code.md)
- GE-0055 [Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers](tools/claude-code.md)
- GE-0074 [tmux resize-pane Silently No-ops for Detached Sessions](tools/tmux.md)
- GE-0075 [tmux capture-pane Output Ends with \n — split() Gives paneHeight+1 Elements](tools/tmux.md)
- GE-0082 [html2text strips trailing whitespace inside bold/italic markers via internal `stressed` flag](tools/html2text.md)
- GE-0083 [BeautifulSoup `prettify()` silently discards trailing whitespace from inline element text nodes](tools/html2text.md)
- GE-0084 [Headless Playwright does not cache iframe responses the way real browsers do — content assertions give false passes](tools/playwright.md)
- GE-0085 [Two `sync_playwright()` context managers in the same pytest session conflict with asyncio](tools/playwright.md)
- GE-0086 [Regex matching social platform names silently strips content paragraphs that mention those platforms as topics](tools/regex.md)
- GE-0087 [Assert that `iframe.src` changes after a save, not that the iframe content changed](tools/playwright.md)
- GE-0088 [Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text](tools/html2text.md)
- GE-0089 [Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()`](tools/html2text.md)
- GE-0090 [html2text `stressed` flag: causes `data.strip()` on first text node inside bold/italic — not documented anywhere](tools/html2text.md)
- GE-0091 [validate_document.py flags markdown tables inside fenced code blocks as corrupted](tools/claude-code.md)
- GE-0092 [Use `.locator().all()` not `.locator().nth(n)` when screenshotting multiple elements of the same class](tools/playwright.md)
- GE-0096 [send-keys silently interprets "Enter"/"Escape" as key names without -l flag](tools/tmux.md)
- GE-0097 [send-keys key name lookup is per-argument, not per-word within an argument](tools/tmux.md)
- GE-0098 [capture-pane pads every output line to full pane width — blank lines are grid artifacts](tools/tmux.md)
- GE-0099 [attach-session fails from ProcessBuilder — requires a real PTY](tools/tmux.md)
- GE-0100 [TUI apps render garbled on WebSocket connect — tmux pane dimensions not synced to browser viewport](tools/tmux.md)
- GE-0101 [`page.evaluate()` does not await async JavaScript functions](tools/playwright.md)
- GE-0102 [`to_be_visible()` fails on elements inside collapsed parent containers](tools/playwright.md)
- GE-0103 [`wait_for_selector(':not(.open)')` waits for visible, but the closed modal is `display:none`](tools/playwright.md)
- GE-0106 [SVG textPath `dy` attribute does not reliably position text below a circular arc line](tools/svg.md)
- GE-0107 [Partial Heading Match in `str.replace()` Corrupts Markdown Headings When Heading Has a Suffix](tools/markdown.md)
- GE-0108 [Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown](tools/markdown.md)
- GE-0113 [`gh auth refresh` Requires an Interactive Terminal — the `!` Prefix in Claude Code Won't Complete the OAuth Flow](tools/github-cli.md)
- GE-0114 [`href="dir/"` serves `index.html` on a web server but opens a directory listing locally](tools/github-pages.md)
- GE-0115 [`maven-compiler-plugin` `<excludes>` Doesn't Prevent Transitive Compilation](tools/maven.md)
- GE-0118 [`git restore --staged .` Also Reverts Working Tree Changes](tools/git.md)

---

## By Symptom / Type

*(requires type metadata per entry — to be built in a dedicated harvest session)*

---

## By Label

### #algorithm
- GE-0034 [Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus](tools/data-structures.md)
- GE-0035 [Trigger exhaustive sweeps by activity count, not time, to match cost to actual need](tools/data-structures.md)
### #analysis
- GE-0043 [Use conventional commit scope as the primary feature-clustering signal over file paths](tools/git.md)
### #appkit
- GE-0073 [NSEvent local monitor + BOOL flag for mode-based key interception](macos-native-appkit/appkit-panama-ffm.md)
### #automation
- GE-0049 [Create and close GitHub issues in bulk with a bash function and URL number extraction](tools/github-cli.md)
- GE-0050 [Use conventional commit scope to cluster commits into issues without reading per-commit diffs](tools/git.md)
- GE-0092 [Use `.locator().all()` not `.locator().nth(n)` when screenshotting multiple elements of the same class](tools/playwright.md)
### #beautifulsoup
- GE-0088 [Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text](tools/html2text.md)
- GE-0089 [Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()`](tools/html2text.md)
### #blogging
- GE-0019 [Generate realistic UI screenshots for blog posts using Playwright headless screenshots](tools/playwright.md)
- GE-0020 [Use `typora-root-url` in YAML front matter to make Jekyll root-relative image paths work in Typora](tools/typora.md)
- GE-0108 [Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown](tools/markdown.md)
### #browser-caching
- GE-0087 [Assert that `iframe.src` changes after a save, not that the iframe content changed](tools/playwright.md)
### #ci-cd
- GE-0006 [Use `>?<` as a safe sed target for SVG text-element replacement in CI](tools/ci-cd.md)
- GE-0039 [Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other](tools/maven.md)
### #claude-cli
- GE-0019 [Generate realistic UI screenshots for blog posts using Playwright headless screenshots](tools/playwright.md)
### #claude-code
- GE-0013 [Inject mandatory instructions directly into an existing session to override ignored guidelines](tools/claude-code.md)
- GE-0054 [Demand-load reference material in Claude Code skills via separate .md files](tools/claude-code.md)
- GE-0055 [Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers](tools/claude-code.md)
### #context
- GE-0013 [Inject mandatory instructions directly into an existing session to override ignored guidelines](tools/claude-code.md)
### #debugging
- GE-0047 [Use javap to find the actual Quarkus config property name from a field annotation](quarkus/config.md)
### #deduplication
- GE-0034 [Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus](tools/data-structures.md)
### #defensive
- GE-0009 [Add a corruption signature check after text transformations that could silently garble content](tools/defensive-programming.md)
- GE-0018 [Test encoding correctness at every pipeline layer with a shared garbling-signature helper](tools/defensive-programming.md)
### #documentation
- GE-0108 [Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown](tools/markdown.md)
### #drools
- GE-0123 [Use Java-Managed Event Buffers + Fresh RuleUnitInstance per Tick Instead of Drools Fusion STREAM Mode for Temporal CEP in Quarkus Rule Units](quarkus/drools-rule-units.md)
### #git
- GE-0002 [Use git -C <path> to operate on a repo without cd-ing into it](tools/git.md)
- GE-0043 [Use conventional commit scope as the primary feature-clustering signal over file paths](tools/git.md)
### #github
- GE-0049 [Create and close GitHub issues in bulk with a bash function and URL number extraction](tools/github-cli.md)
### #html2text
- GE-0088 [Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text](tools/html2text.md)
### #integration
- GE-0071 [Bridge SmallRye in-memory channel to Quarkus Flow using @Incoming + startInstance()](quarkus/quarkus-flow.md)
### #intellij
- GE-0119 [PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated](intellij-platform/plugin-testing.md)
### #java
- GE-0077 [Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean](quarkus/webauthn.md)
### #java-dsl
- GE-0004 [Use typed element return in generator/predicate pairs to enforce cross-API type agreement](java/generics.md)
### #lambda
- GE-0037 [Inject a Supplier<Instant> to test time-dependent logic without sleeping or mocking frameworks](java/clock-testing.md)
### #llm-testing
- GE-0003 [Use a second Claude to verify the first Claude's work — and always confirm the absolute file path](tools/llm-testing.md)
- GE-0012 [Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state](tools/llm-testing.md)
### #macos-native
- GE-0051 [Smoke-test WKWebView rendering by checking for a new WebContent process](macos-native-appkit/appkit-panama-ffm.md)
### #markdown
- GE-0108 [Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown](tools/markdown.md)
### #multi-agent
- GE-0003 [Use a second Claude to verify the first Claude's work — and always confirm the absolute file path](tools/llm-testing.md)
- GE-0012 [Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state](tools/llm-testing.md)
### #multi-repo
- GE-0002 [Use git -C <path> to operate on a repo without cd-ing into it](tools/git.md)
### #panama-ffm
- GE-0039 [Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other](tools/maven.md)
### #pattern
- GE-0021 [Queue debug commands as Runnables in the S2Agent for cross-thread execution in onStep()](tools/ocraft-s2client.md)
- GE-0040 [Use `waitpid(WNOHANG)` polling to verify signal delivery in subprocess tests](tools/testing-patterns.md)
- GE-0071 [Bridge SmallRye in-memory channel to Quarkus Flow using @Incoming + startInstance()](quarkus/quarkus-flow.md)
- GE-0073 [NSEvent local monitor + BOOL flag for mode-based key interception](macos-native-appkit/appkit-panama-ffm.md)
- GE-0077 [Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean](quarkus/webauthn.md)
- GE-0089 [Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()`](tools/html2text.md)
- GE-0095 [Use a dedicated @QuarkusTest class with @InjectMock to isolate side-effectful endpoint tests](quarkus/testing.md)
- GE-0105 [Drools as Action Compiler for GOAP — One Session per Tick, Not per A* Node](drools/drools-goap-planning.md)
- GE-0119 [PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated](intellij-platform/plugin-testing.md)
- GE-0123 [Use Java-Managed Event Buffers + Fresh RuleUnitInstance per Tick Instead of Drools Fusion STREAM Mode for Temporal CEP in Quarkus Rule Units](quarkus/drools-rule-units.md)
### #performance
- GE-0054 [Demand-load reference material in Claude Code skills via separate .md files](tools/claude-code.md)
- GE-0105 [Drools as Action Compiler for GOAP — One Session per Tick, Not per A* Node](drools/drools-goap-planning.md)
### #playwright
- GE-0087 [Assert that `iframe.src` changes after a save, not that the iframe content changed](tools/playwright.md)
### #preprocessing
- GE-0088 [Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text](tools/html2text.md)
### #prettify
- GE-0089 [Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()`](tools/html2text.md)
### #quarkus
- GE-0033 [Use `@UnlessBuildProfile("prod")` to strip debug/QA beans from production at CDI level](quarkus/cdi.md)
- GE-0047 [Use javap to find the actual Quarkus config property name from a field annotation](quarkus/config.md)
- GE-0077 [Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean](quarkus/webauthn.md)
### #security
- GE-0033 [Use `@UnlessBuildProfile("prod")` to strip debug/QA beans from production at CDI level](quarkus/cdi.md)
### #strategy
- GE-0003 [Use a second Claude to verify the first Claude's work — and always confirm the absolute file path](tools/llm-testing.md)
- GE-0009 [Add a corruption signature check after text transformations that could silently garble content](tools/defensive-programming.md)
- GE-0010 [Order dependent artifact creation by information flow, not by convention](tools/workflow.md)
- GE-0012 [Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state](tools/llm-testing.md)
- GE-0018 [Test encoding correctness at every pipeline layer with a shared garbling-signature helper](tools/defensive-programming.md)
- GE-0022 [Dual-runner scenario library: same named tests run against mock and real system](tools/testing-patterns.md)
- GE-0025 [Use a stateful mock as a living specification that accumulates knowledge of the real system](tools/testing-patterns.md)
- GE-0034 [Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus](tools/data-structures.md)
- GE-0035 [Trigger exhaustive sweeps by activity count, not time, to match cost to actual need](tools/data-structures.md)
- GE-0043 [Use conventional commit scope as the primary feature-clustering signal over file paths](tools/git.md)
- GE-0050 [Use conventional commit scope to cluster commits into issues without reading per-commit diffs](tools/git.md)
- GE-0105 [Drools as Action Compiler for GOAP — One Session per Tick, Not per A* Node](drools/drools-goap-planning.md)
### #svg
- GE-0006 [Use `>?<` as a safe sed target for SVG text-element replacement in CI](tools/ci-cd.md)
### #technique
- GE-0019 [Generate realistic UI screenshots for blog posts using Playwright headless screenshots](tools/playwright.md)
### #testing
- GE-0018 [Test encoding correctness at every pipeline layer with a shared garbling-signature helper](tools/defensive-programming.md)
- GE-0021 [Queue debug commands as Runnables in the S2Agent for cross-thread execution in onStep()](tools/ocraft-s2client.md)
- GE-0022 [Dual-runner scenario library: same named tests run against mock and real system](tools/testing-patterns.md)
- GE-0025 [Use a stateful mock as a living specification that accumulates knowledge of the real system](tools/testing-patterns.md)
- GE-0037 [Inject a Supplier<Instant> to test time-dependent logic without sleeping or mocking frameworks](java/clock-testing.md)
- GE-0039 [Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other](tools/maven.md)
- GE-0040 [Use `waitpid(WNOHANG)` polling to verify signal delivery in subprocess tests](tools/testing-patterns.md)
- GE-0051 [Smoke-test WKWebView rendering by checking for a new WebContent process](macos-native-appkit/appkit-panama-ffm.md)
- GE-0061 [Use tput to verify PTY window dimensions in JVM-mode Panama FFM tests](java-panama-ffm/pty-patterns.md)
- GE-0087 [Assert that `iframe.src` changes after a save, not that the iframe content changed](tools/playwright.md)
- GE-0092 [Use `.locator().all()` not `.locator().nth(n)` when screenshotting multiple elements of the same class](tools/playwright.md)
- GE-0095 [Use a dedicated @QuarkusTest class with @InjectMock to isolate side-effectful endpoint tests](quarkus/testing.md)
- GE-0119 [PSI Scan Fallback for IntelliJ Plugin Tests When Custom FileBasedIndex Isn't Populated](intellij-platform/plugin-testing.md)
### #token-budget
- GE-0054 [Demand-load reference material in Claude Code skills via separate .md files](tools/claude-code.md)
- GE-0055 [Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers](tools/claude-code.md)
### #tooling
- GE-0020 [Use `typora-root-url` in YAML front matter to make Jekyll root-relative image paths work in Typora](tools/typora.md)
### #trigger-hygiene
- GE-0055 [Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers](tools/claude-code.md)
### #workaround
- GE-0061 [Use tput to verify PTY window dimensions in JVM-mode Panama FFM tests](java-panama-ffm/pty-patterns.md)
### #workflow
- GE-0010 [Order dependent artifact creation by information flow, not by convention](tools/workflow.md)
- GE-0013 [Inject mandatory instructions directly into an existing session to override ignored guidelines](tools/claude-code.md)
- GE-0035 [Trigger exhaustive sweeps by activity count, not time, to match cost to actual need](tools/data-structures.md)
