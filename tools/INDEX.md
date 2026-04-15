# tools Index

| ID | Title | Type | Score |
|----|----|-------|-------|
| GE-0002 | Use git -C <path> to operate on a repo without cd-ing into it | technique | 8/15 |
| GE-0003 | Use a second Claude to verify the first Claude's work — and always confirm the absolute file path | technique | 11/15 |
| GE-0006 | Use `>?<` as a safe sed target for SVG text-element replacement in CI | technique | 9/15 |
| GE-0009 | Add a corruption signature check after text transformations that could silently garble content | technique | 11/15 |
| GE-0010 | Order dependent artifact creation by information flow, not by convention | technique | 13/15 |
| GE-0011 | Commit messages describe intent, not content — Claude can be confidently wrong about file state | gotcha | 13/15 |
| GE-0012 | Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state | technique | 14/15 |
| GE-0013 | Inject mandatory instructions directly into an existing session to override ignored guidelines | technique | 10/15 |
| GE-0015 | Browser cache hides a server fix — tests pass, user still sees the bug | gotcha | 13/15 |
| GE-0018 | Test encoding correctness at every pipeline layer with a shared garbling-signature helper | technique | 13/15 |
| GE-0019 | Generate realistic UI screenshots for blog posts using Playwright headless screenshots | technique | 10/15 |
| GE-0020 | Use `typora-root-url` in YAML front matter to make Jekyll root-relative image paths work in Typora | technique | 10/15 |
| GE-0021 | Queue debug commands as Runnables in the S2Agent for cross-thread execution in onStep() | technique | 12/15 |
| GE-0022 | Dual-runner scenario library: same named tests run against mock and real system | technique | 12/15 |
| GE-0025 | Use a stateful mock as a living specification that accumulates knowledge of the real system | technique | 13/15 |
| GE-0026 | ocraft `S2Coordinator` builder ends with `.launchStarcraft()` — there is no `.create()` terminal call | gotcha | 10/15 |
| GE-0027 | ocraft `agent.debug()` NPEs if called outside `onStep()` — debug interface only initialised during game loop | gotcha | 13/15 |
| GE-0028 | ocraft `DebugInterface` has no `debugSetMinerals(int)` — precise resource setting requires raw protobuf | gotcha | 12/15 |
| GE-0029 | ocraft unit observation returns `UnitInPool` wrapper with Optional fields — not plain `Unit` objects | gotcha | 14/15 |
| GE-0030 | ocraft `Units` enum uses full underscore separation for multi-word building names | gotcha | 11/15 |
| GE-0034 | Use a sparse pair log to avoid O(N²) re-comparison across a growing corpus | technique | 13/15 |
| GE-0035 | Trigger exhaustive sweeps by activity count, not time, to match cost to actual need | technique | 12/15 |
| GE-0039 | Use surefire `reuseForks=false` to isolate Panama FFM native I/O tests from each other | technique | 11/15 |
| GE-0040 | Use `waitpid(WNOHANG)` polling to verify signal delivery in subprocess tests | technique | 11/15 |
| GE-0042 | Python `format(?:ting|ted|s)?` matches "formats" (plural noun) — false positive in text classifiers | gotcha | 11/15 |
| GE-0043 | Use conventional commit scope as the primary feature-clustering signal over file paths | technique | 12/15 |
| GE-0044 | MADR `Date:` field is never auto-populated — always empty unless manually set | gotcha | 13/15 |
| GE-0048 | Large Bash tool output is saved to a temp file — `cat` on that path loops; use Read tool | gotcha | 10/15 |
| GE-0049 | Create and close GitHub issues in bulk with a bash function and URL number extraction | technique | 11/15 |
| GE-0050 | Use conventional commit scope to cluster commits into issues without reading per-commit diffs | technique | 10/15 |
| GE-0054 | Demand-load reference material in Claude Code skills via separate .md files | technique | 13/15 |
| GE-0055 | Restrict Claude Code skill CSO triggers to explicit user invocation; use pointer mentions in callers | technique | 12/15 |
| GE-0074 | tmux resize-pane Silently No-ops for Detached Sessions | gotcha | 14/15 |
| GE-0075 | tmux capture-pane Output Ends with 
 — split() Gives paneHeight+1 Elements | gotcha | 12/15 |
| GE-0082 | html2text strips trailing whitespace inside bold/italic markers via internal `stressed` flag | gotcha | 13/15 |
| GE-0083 | BeautifulSoup `prettify()` silently discards trailing whitespace from inline element text nodes | gotcha | 12/15 |
| GE-0084 | Headless Playwright does not cache iframe responses the way real browsers do — content assertions give false passes | gotcha | 12/15 |
| GE-0085 | Two `sync_playwright()` context managers in the same pytest session conflict with asyncio | gotcha | 11/15 |
| GE-0086 | Regex matching social platform names silently strips content paragraphs that mention those platforms as topics | gotcha | 9/15 |
| GE-0087 | Assert that `iframe.src` changes after a save, not that the iframe content changed | technique | 13/15 |
| GE-0088 | Move trailing whitespace from inside inline HTML elements to after the closing tag before html2text | technique | 11/15 |
| GE-0089 | Use Unicode WORD JOINER (U+2060) as an invisible reversible marker to preserve adjacency information through BeautifulSoup `prettify()` | technique | 10/15 |
| GE-0090 | html2text `stressed` flag: causes `data.strip()` on first text node inside bold/italic — not documented anywhere | undocumented | 11/15 |
| GE-0091 | validate_document.py flags markdown tables inside fenced code blocks as corrupted | gotcha | 11/15 |
| GE-0092 | Use `.locator().all()` not `.locator().nth(n)` when screenshotting multiple elements of the same class | gotcha | 10/15 |
| GE-0096 | send-keys silently interprets "Enter"/"Escape" as key names without -l flag | gotcha | 8/15 |
| GE-0097 | send-keys key name lookup is per-argument, not per-word within an argument | gotcha | 8/15 |
| GE-0098 | capture-pane pads every output line to full pane width — blank lines are grid artifacts | gotcha | 8/15 |
| GE-0099 | attach-session fails from ProcessBuilder — requires a real PTY | gotcha | 8/15 |
| GE-0100 | TUI apps render garbled on WebSocket connect — tmux pane dimensions not synced to browser viewport | gotcha | 8/15 |
| GE-0101 | `page.evaluate()` does not await async JavaScript functions | gotcha | 8/15 |
| GE-0102 | `to_be_visible()` fails on elements inside collapsed parent containers | gotcha | 8/15 |
| GE-0103 | `wait_for_selector(':not(.open)')` waits for visible, but the closed modal is `display:none` | gotcha | 8/15 |
| GE-0106 | SVG textPath `dy` attribute does not reliably position text below a circular arc line | gotcha | 13/15 |
| GE-0107 | Partial Heading Match in `str.replace()` Corrupts Markdown Headings When Heading Has a Suffix | gotcha | 8/15 |
| GE-0108 | Use Deprecated HTML `align` Attribute (Not `style="float"`) for Image Wrapping in Markdown | technique | 12/15 |
| GE-0113 | `gh auth refresh` Requires an Interactive Terminal — the `!` Prefix in Claude Code Won't Complete the OAuth Flow | gotcha | 10/15 |
| GE-0114 | `href="dir/"` serves `index.html` on a web server but opens a directory listing locally | gotcha | 9/15 |
| GE-0115 | `maven-compiler-plugin` `<excludes>` Doesn't Prevent Transitive Compilation | gotcha | 13/15 |
| GE-0118 | `git restore --staged .` Also Reverts Working Tree Changes | gotcha | 10/15 |
| GE-0121 | `mv` Project Folder Invalidates Bash Tool's Shell cwd Mid-Session | gotcha | 11/15 |
| GE-0124 | Renaming a Claude Code Project Directory Leaves Stale Absolute Paths in `.claude/settings.local.json` | gotcha | 12/15 |
| GE-0127 | Use `terminal.paste()` not `ws.send()` to inject text into an xterm.js terminal from JavaScript | technique | 13/15 |
| GE-0129 | iframe swallows mousemove events when the cursor enters it during a drag | gotcha | 11/15 |
| GE-0130 | `JSON.stringify()` in HTML onclick attribute silently truncates at the first inner double-quote | gotcha | 11/15 |
| GE-0132 | Walk text character-by-character tracking quote state to skip keyword matching inside strings | technique | 11/15 |
| GE-0135 | Return resolved data instead of calling a complex interface directly — eliminates mocking even with 12+ overloads | technique | 11/15 |
| GE-0136 | Structured text validators produce false positives from markers inside fenced code blocks | gotcha | 12/15 |
| GE-0137 | `git push` to a non-bare repo is rejected when the target branch is checked out | gotcha | 12/15 |
| GE-0140 | `git filter-branch --msg-filter` doubles footers already in commit bodies — two-pass required | gotcha | 11/15 |
| GE-0141 | Use `$GIT_COMMIT` in `--msg-filter` to selectively rewrite only specific commits by hash | technique | 11/15 |
| GE-0145 | Playwright Java: `waitForFunction(String, WaitForFunctionOptions)` silently serialises options as JS arg | gotcha | 12/15 |
| GE-0147 | Java 11 WebSocket: `ws.request(N)` must be called before `onText` fires | gotcha | 12/15 |
| GE-0149 | Maven Surefire: profile `<excludedGroups/>` doesn't clear base config — use `combine.self="override"` | gotcha | 11/15 |
| GE-0150 | Expose `window.__test` semantic API for robust canvas/WebGL test assertions | technique | 13/15 |
| GE-0151 | Prove WebSocket end-to-end connectivity by waiting for first message, not just `onOpen` | technique | 12/15 |
| GE-0152 | PixiJS 8: Graphics mask added as child of anchored Sprite makes Sprite invisible | gotcha | 13/15 |
| GE-0153 | CSS `var()` in an iframe `<style>` tag silently produces no output | gotcha | 15/15 |
| GE-0154 | Replacing a CSS rule block silently deletes adjacent rules not included in the replacement | gotcha | 13/15 |
| GE-0155 | SVG `fill=""` presentation attributes don't reliably resolve CSS custom properties | gotcha | 12/15 |
| GE-0156 | macOS `sed -i ''` silently empties a file when the pattern contains `**` (double asterisk) | gotcha | 13/15 |
| GE-0157 | macOS tmp filesystem full silently blocks all Claude Code Bash tool commands | gotcha | 13/15 |
| GE-0159 | Gitignored CLAUDE.md symlink for consistent AI workspace config across entry points | gotcha | 14/15 |
| GE-0161 | `gh project item-edit --field-id` rejects field names — requires internal GraphQL node ID | gotcha | 11/15 |
| GE-0162 | Gradle 8.6 fails cryptically when JAVA_HOME points to Java 26 | gotcha | 10/15 |
| GE-0166 | Dispatch parallel agents for exhaustive cross-codebase comparison | gotcha | 13/15 |
| GE-0169 | Assert on side effects, not LLM output, when testing AI tool use | technique | 8/15 |
| GE-0170 | Use real LLM invocations as protocol capture, replace with scripted replay for CI | technique | 8/15 |
| GE-0171 | Use claude `--mcp-config` + `--strict-mcp-config` to test MCP servers in isolation | technique | 8/15 |
| GE-0172 | `claude` CLI subprocess uses keychain OAuth — ANTHROPIC_API_KEY not required on dev machines | gotcha | 8/15 |
| GE-0174 | `git filter-branch` fails with staged changes — even for message-only rewrites | gotcha | 10/15 |
| GE-0175 | Merging a branch with `--delete-branch` auto-closes any PR targeting that branch | gotcha | 11/15 |
| GE-0177 | Python `HTTPServer('localhost', port)` may bind to IPv6 on macOS 14+ — health checks on 127.0.0.1 then fail | gotcha | 12/15 |
| GE-0178 | Use `git filter-branch --msg-filter` with a Python hash→refs mapping to bulk-add commit footers | technique | 11/15 |
| GE-0180 | `jest.useFakeTimers()` also fakes `setImmediate` — mock process exit events hang | gotcha | 12/15 |
| GE-20260412-17c8ce | Enable GitHub Pages Actions source and fix branch protection via gh API — no browser | technique | 12/15 |
| GE-20260412-48e9e2 | GitHub Pages 'Deploy from branch' ignores your Gemfile and builds with Jekyll 3.9 | gotcha | 14/15 |
| GE-20260412-b6c0f8 | Claude Code Read tool fails on files over ~256KB — use offset/limit or Bash grep | gotcha | 8/15 |
| GE-20260412-e4773d | Python regex alternation matches leftmost option — longer pattern must come before any pattern that is a prefix of it | gotcha | 11/15 |
| GE-20260414-3d73c3 | Structure architecture docs as property claims with Guarantees and Graceful Degradation | technique | 14/15 |
| GE-20260414-c08ba3 | `gh issue close` only accepts one issue number — bulk close requires a loop | gotcha | 9/15 |
