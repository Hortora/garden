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
| GE-20260518-2de2f8 | Maven SNAPSHOT jar from sibling branch persists in .m2 — tests fail with constructor mismatch | gotcha | 10/15 |
| GE-20260518-d1775a | git cherry-pick -X ours brings in new files cleanly but silently discards field additions in conflicted files | gotcha | 11/15 |
| GE-20260518-3adcb9 | git diff main..<branch> shows files as 'Added' when main deleted them but the branch predates the deletion | gotcha | 8/15 |
| GE-20260518-e7b226 | Read any branch's files without checkout using git show and git ls-tree | technique | 10/15 |
| GE-20260518-4b7541 | Apply journal merges to main before merging two epics that both modify DESIGN.md | technique | 8/15 |
| GE-20260518-ae7612 | Bash tool CWD resets between tool calls — jar xf then javap in separate calls uses wrong directory | gotcha | 11/15 |
| GE-20260518-554158 | git add -A silently stages nested git repo as a submodule (mode 160000) | gotcha | 10/15 |
| GE-20260518-cf67e4 | git cherry-pick -X ours silently drops feature code from conflicting files | gotcha | 14/15 |
| GE-20260518-96bd10 | IntelliJ MCP get_file_text_by_path and read_file return stale cached content diverging from on-disk file | gotcha | 14/15 |
| GE-20260518-6e11a4 | Resolve knowledge scope at capture time to prevent audit debt | technique | 14/15 |
| GE-20260519-c93fd8 | `git add -A` after targeted `git checkout <branch> -- <files>` stages all untracked files, not just checked-out ones | gotcha | 11/15 |
| GE-20260519-54d86a | git filter-repo --refs flag does not exempt the non-fresh-clone safety check | gotcha | 11/15 |
| GE-20260520-be8d9e | git filter-repo --force on a non-fresh clone rewrites all SHAs, breaking origin/branch..HEAD range | gotcha | 12/15 |
| GE-20260520-03f1a7 | cc-praxis: hooks/check_project_setup.sh is the canonical source — not install-skills/SKILL.md | gotcha | 13/15 |
| GE-20260520-9807cd | git stash on feature branch: stash pop returns you to that branch — subsequent commits land on it, not main | gotcha | 9/15 |
| GE-20260520-ebd8b7 | Semantic Scholar public API returns full citation networks programmatically — no scraping needed | undocumented | 11/15 |
| GE-20260520-836d5b | cc-praxis sync-local silently updates the deployed session-start hook — indicated only by a status message | undocumented | 11/15 |
| GE-20260520-7fb7a8 | Claude Code Edit replace_all corrupts variable definition when pattern appears in both definition and call sites | gotcha | 10/15 |
| GE-20260521-b6a1a7 | git merge --ff-only brings branch-only workflow markers (.meta, EPIC-CLOSED.md) to main | gotcha | 10/15 |
| GE-20260521-340888 | git branch --merged reports cherry-picked branches as NOT merged — SHA-based, not content-based | gotcha | 10/15 |
| GE-20260521-cb1eea | git diff A...B (three-dot) shows branch's changes since divergence — not what's missing from main | gotcha | 10/15 |
| GE-20260521-c89fd1 | Resolve cherry-pick conflict by checking out the mature-branch version of the whole file | technique | 11/15 |
| GE-20260521-50acf0 | grep -c with || echo 0 produces double-line output — non-empty check sees clean repo as dirty | gotcha | 11/15 |
| GE-20260521-53dae7 | git stash exits 0 with 'No local changes to save' — recording stash@{0} points at the previous stash | gotcha | 10/15 |
| GE-20260521-523b94 | A && B || C shell pattern is not if/else — C runs when A is false, not only when B fails | gotcha | 9/15 |
| GE-20260521-5446cf | Uniform 'N commits behind upstream' across all local branches signals squash-merged stale branches | technique | 11/15 |
| GE-20260521-eaa1e1 | git rebase $BRANCH while on main replays main's commits onto the branch tip, not the other way | gotcha | 10/15 |
| GE-20260413-66dbe0 | Jekyll permalink: pretty silently breaks all relative image paths | gotcha | 15/15 |
| GE-20260413-7f2e60 | Chain Liquid replace filters in Jekyll layouts to fix relative paths without touching source files | technique | 15/15 |
| GE-20260413-83d434 | ImageMagick `convert` silently shadowed by macOS built-in — use `magick` instead | gotcha | 12/15 |
| GE-20260413-83dedd | GitHub Pages `configure-pages` action fails if Pages not enabled via API first | gotcha | 10/15 |
| GE-20260413-c7dc5b | python-build-standalone Windows archive is .tar.gz not .zip — and has no shared/static discriminator | gotcha | 12/15 |
| GE-20260414-007a93 | Use a module-level configurable dict for scoring/bonus rules so strategy is data not code | technique | 11/15 |
| GE-20260414-0a7d31 | bash $() strips trailing newlines — git commit --amend footer concatenates to last line | gotcha | 10/15 |
| GE-20260414-119352 | macOS BSD sed silently ignores \b word boundaries — use perl for Java class renames | gotcha | 13/15 |
| GE-20260414-338984 | sed appends trailing comment inside a Python string argument when the string is the last positional arg | gotcha | 9/15 |
| GE-20260414-4d4976 | Validator cross-checks silently do nothing when their HTML dependency is absent | gotcha | 9/15 |
| GE-20260414-55f1ed | Cherry-pick loop to rewrite commit messages without interactive rebase | technique | 11/15 |
| GE-20260414-5687e0 | mvn test -pl <module> fails with 'cannot find symbol' when sibling module has new classes not yet installed | gotcha | 11/15 |
| GE-20260414-6c9bfc | gh pr create requires --body even when --title is provided in non-interactive mode | gotcha | 9/15 |
| GE-20260414-736039 | Subagent prompts must explicitly include issue-workflow steps — CLAUDE.md automatic behaviours don't propagate | gotcha | 10/15 |
| GE-20260414-8c43a9 | ConcurrentHashMap<ID, CompletableFuture> registry for suspending workflows pending external events | technique | 12/15 |
| GE-20260414-db76e9 | `git worktree remove` fails after merge when worktree was used as subagent CWD | gotcha | 10/15 |
| GE-20260414-f0bfd8 | Dispatch TDD subagents with 'read source first, then write tests' instruction to get targeted assertions | technique | 10/15 |
| GE-20260415-0761e9 | Floating-point boundary check with == speed is fragile — use a smaller arrival threshold | gotcha | 8/15 |
| GE-20260415-1788e5 | fitAddon.fit() is a no-op in headless Playwright — terminal.onResize never fires | gotcha | 12/15 |
| GE-20260415-20f08f | Playwright page.request() does not inherit page.setExtraHTTPHeaders() | gotcha | 11/15 |
| GE-20260415-2af3bb | Assert derived values via the same source as the implementation — not hardcoded magic numbers | technique | 10/15 |
| GE-20260415-5aac89 | PixiJS 8: tile-rectangle top-left uses (VIEWPORT_H - y - 1) * SCALE — not the point formula | gotcha | 10/15 |
| GE-20260415-7ca64f | Truncated hash as SQL primary key with INSERT OR IGNORE silently discards rows on collision | gotcha | 12/15 |
| GE-20260415-84faaf | Git branch naming conflict: can't create a branch whose name is a prefix of an existing branch path | gotcha | 9/15 |
| GE-20260415-8d619d | Bare .gitignore pattern matches all files with that name recursively, including deeply nested ones | gotcha | 10/15 |
| GE-20260415-95b40f | git textconv driver makes binary file diffs human-readable — SQLite databases show as SQL dumps in git diff | technique | 10/15 |
| GE-20260415-d07a2c | FastMCP serializes list tool returns as one TextContent per element — empty list produces zero content items | gotcha | 11/15 |
| GE-20260415-ec4471 | Stacked PRs from a fork: push the base branch to upstream first | technique | 10/15 |
| GE-20260416-41a9cb | PixiJS Graphics loop over full grid size draws invisible off-screen tiles silently | gotcha | 9/15 |
| GE-20260416-5df109 | `podman machine rm` permanently destroys the VM — it is not a stop command | gotcha | 8/15 |
| GE-20260416-a5e990 | `git cherry-pick --continue` applies all remaining queued commits, not just the conflicted one | gotcha | 9/15 |
| GE-20260416-eb035d | GitHub stacked PRs from a fork: base branch must exist on the upstream repo, not the fork | gotcha | 9/15 |
| GE-20260417-29c2e3 | File-naming trick for top-level inline templates: name file after output class, template class differently | technique | 10/15 |
| GE-20260417-3b862c | jar xf without -C extracts to the current working directory, not a temp dir | gotcha | 10/15 |
| GE-20260417-988839 | WorldState.get() returns false for absent keys — open-world semantics | undocumented | 10/15 |
| GE-20260417-a1f3e9 | Maven plugin keepTemplate=true with inline=false writes template class to generated sources | undocumented | 9/15 |
| GE-20260417-a420df | PR base becomes stale when upstream maintainer merges your content as a new PR directly to main | gotcha | 10/15 |
| GE-20260417-a7f7fc | GOAP cheaper plan bypasses intended action when precondition complement is missing | gotcha | 10/15 |
| GE-20260417-c6e3db | GOAP wrong goal key produces empty plan — units idle with no error | gotcha | 11/15 |
| GE-20260417-def63b | Python one-liner to resolve all merge conflicts in a file by uniformly taking one side | technique | 9/15 |
| GE-20260417-f661fd | GOAP action correctness: verify reachability and goal-advancement independently | technique | 12/15 |
| GE-20260417-fdb17f | Create clean branch from target base + cherry-pick only new commits when old branch has accumulated already-merged content | technique | 11/15 |
| GE-20260418-8edb81 | Tamboui TestBackend is in tamboui-core:test-fixtures, not tamboui-tui:test-fixtures | undocumented | 12/15 |
| GE-20260418-b5775c | Playwright Java waitForFunction requires explicit null arg — passing options as second arg silently misbehaves | gotcha | 11/15 |
| GE-20260420-146d7c | sed range deletion /start/,/end/d corrupts XML when the end pattern appears multiple times | gotcha | 8/15 |
| GE-20260420-1ffdff | git rebase with 40+ commits onto diverged upstream cascades into unmanageable conflicts — use fresh branch + diff patch instead | gotcha | 9/15 |
| GE-20260420-374a25 | Dispatch parallel implementation subagents within subagent-driven-development for disjoint tasks | technique | 9/15 |
| GE-20260420-500405 | Inspect nested ZIP/JSON structure with a Python one-liner before writing any typed-language parsing code | technique | 9/15 |
| GE-20260420-5df542 | Split a large single-commit branch into stacked PRs using git diff patches — no interactive rebase needed | technique | 9/15 |
| GE-20260420-89f0c6 | gh issue create does not support --json flag — capture issue number by parsing stdout URL | gotcha | 8/15 |
| GE-20260420-ca3fb3 | str.replace with list[0] silently no-ops when list order changes | gotcha | 9/15 |
| GE-20260420-dc3c2f | Separating observed_at from indexed_at makes time-series backfill free | technique | 11/15 |
| GE-20260420-de730c | git rebase-merge directory persists after session ends mid-rebase — blocks new rebases on any branch | gotcha | 10/15 |
| GE-20260420-e3f2c4 | Claude Code response size limit (~32k) is separate from context window — large plan generation silently kills the session | gotcha | 13/15 |
| GE-20260421-368e34 | Use a terrainReady flag in window.__test instead of threeReady when loadTerrain() is async — prevents Playwright race | technique | 9/15 |
| GE-20260421-49a3ca | tmux #{pane_activity} is blank without an attached client — use #{window_activity}; display-message requires -t before -p | gotcha | 10/15 |
| GE-20260421-5817bb | Superpowers brainstorm server serves static files from the content dir at /files/<filename> — not documented in the skill | undocumented | 8/15 |
| GE-20260421-654530 | GitHub PR mergeable status is asynchronous after force push — stays CONFLICTING for 1+ minutes | gotcha | 9/15 |
| GE-20260421-690e47 | Inject a decide_fn callback to make interactive CLI tools fully unit-testable | technique | 11/15 |
| GE-20260421-954775 | Trace iterative algorithms by hand for 3-4 iterations before coding to catch silent convergence failures | technique | 9/15 |
| GE-20260421-ac2a7b | gh run view --log-failed shows only failing CI step logs — fast alternative to browser navigation | technique | 9/15 |
| GE-20260421-c8fdb8 | sed -i '' silently truncates Java files with generics on macOS | gotcha | 12/15 |
| GE-20260421-d1580e | Passing new Map() per call as a tracking meshMap leaks 3D objects — they are added but can never be removed | gotcha | 10/15 |
| GE-20260421-e580ee | Two-constructor CDI pattern: @Inject for production wiring, package-private for unit tests without Quarkus boot | technique | 12/15 |
| GE-20260421-ef0a4e | Refactoring tests to extend an abstract base class silently removes implementation-specific test methods | gotcha | 9/15 |
| GE-20260421-f8f11c | Squash multi-commit PR with repeated GARDEN.md conflicts into a single clean commit | technique | 10/15 |
| GE-20260422-164498 | Use scene.traverse() + getWorldPosition() in Playwright to catch off-map geometry without visual inspection | technique | 11/15 |
| GE-20260422-273e02 | zsh variable-as-command shorthand fails when the command string contains arguments | gotcha | 8/15 |
| GE-20260422-2afcb2 | Quoted heredoc delimiter prevents variable expansion in bash installer embedded scripts | technique | 10/15 |
| GE-20260422-390ac3 | Substring occurrence count in tests breaks when a new line contains the same substring | gotcha | 9/15 |
| GE-20260422-4407a2 | GitHub 'Closes #N' commit messages don't reliably auto-close issues on direct push to main | gotcha | 9/15 |
| GE-20260422-458078 | Spawn a research agent with targeted academic + standards queries to drive architecture decisions | technique | 9/15 |
| GE-20260422-75b92e | git checkout/rebase on a branch checked out in a worktree fails — use git -C <worktree-path> instead | gotcha | 10/15 |
| GE-20260422-8d2613 | Sentinel-guarded heredoc append for idempotent bash installer blocks | technique | 11/15 |
| GE-20260422-8e9873 | GitHub /retest bot comment produces 'completed skipped' workflow — use gh run rerun --failed instead | gotcha | 9/15 |
| GE-20260422-9d2c28 | Use grep -l across files to identify cross-file method duplication before extracting to shared utility | technique | 9/15 |
| GE-20260422-b3423e | Visually duplicate methods across two files may have silently diverged — extraction reveals hidden differences | gotcha | 12/15 |
| GE-20260422-b45302 | Wrapper script eliminates shell expansion prompts in Claude Code agents without disabling security | technique | 11/15 |
| GE-20260422-c0181c | garden_db_migrate.py leaves an empty GE-20260421-test999.md artifact after migration | gotcha | 8/15 |
| GE-20260422-ceb229 | git rebase --onto silently drops commits already present upstream — prints 'patch contents already upstream' | undocumented | 10/15 |
| GE-20260422-e5e20f | Cascade rebase a chain of dependent PRs onto new base using captured old tips and git rebase --onto | technique | 11/15 |
| GE-20260423-1593b7 | Read a live JS variable from the Playwright page to make Java assertion thresholds profile-aware | technique | 10/15 |
| GE-20260423-522c5a | Design MCP @ToolArg descriptions as LLM classification prompts for typed enumerations | technique | 10/15 |
| GE-20260423-5f606b | git push --force-with-lease rejected after local history rewrite | gotcha | 11/15 |
| GE-20260423-aed486 | git filter-repo silently removes the origin remote on every run | gotcha | 12/15 |
| GE-20260423-af9030 | Describe sprite visuals in plans instead of writing draw code — keeps batched plans under LLM token limits | technique | 10/15 |
| GE-20260423-d40b93 | Playwright scene-object count passes when units are fogged — visual invisibility is not tested | gotcha | 11/15 |
| GE-20260424-12e346 | ocraft 0.4.21 Abilities enum is missing several Zerg and Protoss build/morph constants | undocumented | 9/15 |
| GE-20260424-3f5e60 | GitHub repo transfer API returns 200 immediately but transfer completes asynchronously | gotcha | 8/15 |
| GE-20260424-64118d | gh repo transfer has no --yes flag — use the API directly | gotcha | 8/15 |
| GE-20260424-7955ee | Three.js tile-coord visualizer: negative game-tile z values map outside world bounds and silently disappear | gotcha | 10/15 |
| GE-20260424-918740 | XML comment containing '--' crashes Maven with Non-parseable POM | gotcha | 9/15 |
| GE-20260424-ccdff5 | sed replace of a SNAPSHOT version in a pom corrupts parent version declarations | gotcha | 9/15 |
| GE-20260426-0915b7 | Poll a semantically-meaningful ready signal, not just HTTP 200, for fast-starting services | technique | 10/15 |
| GE-20260426-165fd9 | jq @base64 wraps output at 76 chars — breaks while-read-r line-by-line parsing in bash | gotcha | 12/15 |
| GE-20260426-1a8caf | git stash one-liner to baseline-check if a build failure pre-existed your change | technique | 8/15 |
| GE-20260426-3e6b29 | maven-deploy-plugin retryFailedDeploymentCount retries with zero delay — useless for GitHub Packages first-upload | undocumented | 9/15 |
| GE-20260426-4576d1 | GitHub Pages environment protection custom branch policy silently blocks main after stale branch entry | gotcha | 9/15 |
| GE-20260426-5800d0 | SC2 .SC2Map terrain file t3SyncCliffLevel: binary format and cliff-tier encoding | undocumented | 13/15 |
| GE-20260426-5c059f | Use jq @tsv + IFS=$'\t' read to iterate multi-field JSON objects in bash without base64 | technique | 11/15 |
| GE-20260426-611fdc | SC2 replay GAME_EVENTS unit tags encode tagIndex and tagRecycle as a single integer | undocumented | 12/15 |
| GE-20260426-61854e | Create GitHub org team and grant write access to all repos via gh CLI — no browser needed | technique | 10/15 |
| GE-20260426-6ec343 | Strip Unicode control characters before piping GitHub API JSON to jq | technique | 11/15 |
| GE-20260426-805acb | workflow_dispatch trigger definition is cached — adding it doesn't immediately enable manual dispatch | undocumented | 10/15 |
| GE-20260426-840309 | mvn deploy fails on first SNAPSHOT publish to GitHub Packages — metadata lookup error | gotcha | 13/15 |
| GE-20260426-a91e05 | actions/checkout@v6 with ref: <SHA> fails silently when fetch-depth=1 | gotcha | 12/15 |
| GE-20260426-ad8f5a | Maven multi-module: root parent POM must be deployed to GitHub Packages even when maven.deploy.skip=true — downstream consumers need it | gotcha | 12/15 |
| GE-20260426-c8f5c6 | Jekyll defaults: silently ignored on files without YAML frontmatter | gotcha | 10/15 |
| GE-20260426-d58530 | GitHub Packages silently accepts Maven artifact uploads to non-existent repository paths | gotcha | 12/15 |
| GE-20260427-0460f9 | Unicode box-drawing characters misalign in GitHub code blocks — use pure ASCII | gotcha | 9/15 |
| GE-20260427-39f085 | Python len(line.rstrip()) verifies ASCII diagram column alignment where awk fails | technique | 9/15 |
| GE-20260427-a15a51 | Three.js worldToScreen at y=0 misses raycaster hit for sprites with non-zero Y — causes ~27px click offset in isometric view | gotcha | 10/15 |
| GE-20260427-b5ec7a | git add -A before .gitignore on a new repo commits target/ and binaries permanently | gotcha | 9/15 |
| GE-20260427-b90696 | JavaScript .then() promise chains silently swallow TypeErrors — async/await surfaces them | gotcha | 10/15 |
| GE-20260427-f26db0 | Make window.__test helpers async and use page.evaluate('async () =>') to reliably await full UI pipeline in Playwright — eliminates fragile waitForFunction polling | technique | 11/15 |
| GE-20260428-13d4ff | Maven child POM missing snapshotRepository causes SNAPSHOT deploy to parent's registry (403) | gotcha | 10/15 |
| GE-20260428-1ad5c4 | GitHub Actions fork CI deploys to upstream registry using GITHUB_TOKEN — unconditional mvn deploy fails | gotcha | 10/15 |
| GE-20260428-1cc51a | Parallel agent dispatch with worktree isolation completes independent cross-repo tasks simultaneously | technique | 11/15 |
| GE-20260428-222aa0 | Three-state incremental build (BUILD/TEST/SKIP) from SHA comparison across repos | technique | 12/15 |
| GE-20260428-49333e | Use -DaltDeploymentRepository to publish a fork without adding distributionManagement to the pom | technique | 11/15 |
| GE-20260428-5757e3 | Three.js WebGLRenderer preserveDrawingBuffer:false (default) makes canvas pixel sampling silently return black/transparent | gotcha | 11/15 |
| GE-20260428-74de4d | Visual pixel regression pattern for Three.js/WebGL: start real jar as subprocess, aim camera via window.__test, sample WebGL canvas pixel | technique | 13/15 |
| GE-20260428-7cfeab | Three.js transparent plane with depthTest:true (default) is invisible when rendered below an opaque plane at the same position | gotcha | 11/15 |
| GE-20260428-dc4232 | `gh issue create --label` silently fails with 'could not add label' if label doesn't exist in repo | gotcha | 10/15 |
| GE-20260428-f94886 | setup-java server-id only wires credentials for that exact repository id — different ids in pom get 401 | gotcha | 13/15 |
| GE-20260429-52be19 | Rewrite non-HEAD commit message without interactive rebase using git commit-tree | technique | 10/15 |
| GE-20260429-636ef1 | Cross-repo quality audit via parallel subagents after shipping an abstraction | technique | 9/15 |
| GE-20260429-63a862 | Claude Code subagent test result reports are unreliable — always verify independently | gotcha | 10/15 |
| GE-20260429-7d31f6 | `status` is a read-only variable in bash — silent failure when used as a function parameter | gotcha | 9/15 |
| GE-20260429-c455e1 | Agentic code review: Important findings silently dismissed by controller — user never sees them | gotcha | 10/15 |
| GE-20260429-d915d3 | Subagent-driven development: parallel subagents commit unrelated changes to shared branch | gotcha | 8/15 |
| GE-20260429-ef6bdb | git checkout <hash> -- files + stash for non-destructive pre-existing regression triage | technique | 10/15 |
| GE-20260429-f6905c | GitHub Projects v2 `updateProjectV2Field` silently returns null when updating single-select options on an existing field | undocumented | 11/15 |
| GE-20260430-01cc0c | Empty git commit as clean CI re-trigger | technique | 8/15 |
| GE-20260430-01fecd | Parallel agents with domain-split substitution tables for large-scale consistent project-wide renames | technique | 10/15 |
| GE-20260430-6b668c | Subagent-written code changes not committed leave published artifact stale | gotcha | 11/15 |
| GE-20260430-be991b | git worktree unlock/prune works on ghost worktrees whose paths no longer exist | technique | 10/15 |
| GE-20260501-04667c | GitHub Actions steps.outcome vs steps.conclusion — continue-on-error masks real failures | gotcha | 11/15 |
| GE-20260501-0a33bf | Use a Python regex script to safely insert XML blocks into pom.xml files when the target section may not exist | technique | 8/15 |
| GE-20260501-159207 | GitHub fine-grained PATs cannot delete org-level Maven packages even with delete:packages scope visible | gotcha | 12/15 |
| GE-20260501-1fbdc7 | GitHub Packages Maven: HTTP 400 when deleting the last version — must delete the whole package instead | gotcha | 11/15 |
| GE-20260501-28459b | Rebuilding only the Qhorus runtime Maven module leaves the testing module stale — E2E tests fail silently with timeouts, no compile error | gotcha | 11/15 |
| GE-20260501-3372e9 | Use javap + jar/strings on installed JARs and jandex.idx to diagnose API signature changes and tool registration at the bytecode level | technique | 12/15 |
| GE-20260501-4242d8 | Use github.event_name != 'pull_request' as universal GitHub Actions publish guard | technique | 10/15 |
| GE-20260501-66625a | git commit bundles other sessions' staged files — git add <file> does not limit what gets committed | gotcha | 13/15 |
| GE-20260501-71e164 | `gh api` exit code 4 means authentication failure specifically — not a generic error | undocumented | 9/15 |
| GE-20260501-743ff4 | Maven aggregator -pl flag selects only the top-level module — does not recurse into its submodules | gotcha | 12/15 |
| GE-20260501-7835fe | Use GIT_EDITOR=true to auto-accept commit message during non-interactive git rebase --continue | technique | 9/15 |
| GE-20260501-8320ae | GitHub org secret set with --org defaults to private repos — public repos silently get nothing | gotcha | 13/15 |
| GE-20260501-9e8490 | Playwright 1.52: <option> elements inside <select> are never 'visible' — waitFor() with default state times out even when option is in the DOM | gotcha | 13/15 |
| GE-20260501-bc4553 | Probe delete permission with a nonexistent resource ID — 404 means authorised, 403 means denied | technique | 11/15 |
| GE-20260501-c579bb | Chain CI/CD across repos using repository_dispatch — publish upstream, trigger downstream automatically | technique | 11/15 |
| GE-20260501-c836e1 | GitHub Packages org API returns ALL packages in the org — including external groupIds you don't own | gotcha | 12/15 |
| GE-20260501-d7eb0e | Aggressive pre-commit hook silently absorbs staged files into a concurrent commit | gotcha | 11/15 |
| GE-20260501-d9c2d7 | GITHUB_TOKEN returns 403 on cross-repo repository_dispatch — needs classic PAT | gotcha | 12/15 |
| GE-20260501-e6bf89 | GitHub Actions bash: set -e silently kills script on failed command substitution before error handler runs | gotcha | 13/15 |
| GE-20260501-fc1cc6 | GitHub Actions: workflow_dispatch trigger silently skips steps guarded by github.event_name == 'push' | gotcha | 11/15 |
| GE-20260504-209c28 | git push --all exits 0 even when some branches are rejected | gotcha | 10/15 |
| GE-20260504-ae76f6 | Squash-merged PR silently drops commits pushed after the PR was opened | gotcha | 13/15 |
| GE-20260504-b74000 | Doltgres GDPR Art.17 erasure: row deletion leaves PII in git history | gotcha | 11/15 |
| GE-20260504-ba71a8 | GitHub Actions cache/restore + cache/save as separate v4 actions enables failure-aware state persistence | technique | 10/15 |
| GE-20260504-c0c8dc | IntelliJ MCP session ties to IDE lifecycle — HTTP 404 on IDE restart kills in-flight Claude sessions | gotcha | 11/15 |
| GE-20260504-c51f9c | Disable squash/rebase merges across all org repos in one API loop | technique | 10/15 |
| GE-20260504-cb6206 | Split evaluation dimensions into purpose-specific tables to reveal candidate shape, not just rank | technique | 9/15 |
| GE-20260504-e61c56 | gh repo fork creates <name>-1 when name already exists with no warning | gotcha | 9/15 |
| GE-20260504-f5b84c | Use git filter-repo --invert-paths --prune-empty to remove workspace files from history | technique | 11/15 |
| GE-20260505-14159c | init_garden.py writes unbolded drift counter — validate_garden --dedupe-check regex silently reads 0 | gotcha | 12/15 |
| GE-20260505-2718d5 | Parallel bash tool calls share working directory — drift produces silent wrong-repo operations | gotcha | 10/15 |
| GE-20260505-47c2f0 | Counters incremented inside `while read <<< "$VAR"` are not visible to the parent shell in zsh | gotcha | 9/15 |
| GE-20260505-5601ef | `git reset --soft HEAD~1 && git commit --amend --no-edit` — non-interactive squash preserving message | technique | 10/15 |
| GE-20260505-6e554c | Populate GitHub Projects V2 cross-repo via GraphQL node IDs — `gh project item-add` is unreliable for bulk operations | technique | 13/15 |
| GE-20260505-9325a6 | `gh api graphql` returns GitHub HTML error page when mutation is written as a single compact line | gotcha | 10/15 |
| GE-20260505-953bd7 | Explore full ecosystem dependency graph before adding a cross-repo type dependency | technique | 9/15 |
| GE-20260505-9cf5c8 | git mv fails 'not under version control' for files copied but never git-added | gotcha | 10/15 |
| GE-20260505-adae54 | git add -u <dir> stages tracked deletions and triggers git's rename detection | technique | 10/15 |
| GE-20260505-c7db9d | Tile-centre Bresenham LOS passes but continuous movement at speed<1 crosses wall tiles | gotcha | 11/15 |
| GE-20260505-c93a61 | IntelliJ MCP session expires silently mid-session — tool calls return HTTP 404 | gotcha | 8/15 |
| GE-20260505-cc8247 | `git merge-base --is-ancestor` returns false for a merged PR when GitHub used a merge commit | gotcha | 10/15 |
| GE-20260505-d13335 | `gh project item-add --url` exits 0 with no output on both success and silent failure | gotcha | 12/15 |
| GE-20260505-d434ea | Claude Code doc subagents commit to wrong branch in fork model and make false branch state claims | gotcha | 10/15 |
| GE-20260505-d71db6 | ocraft ImageData.getData() returns byte[] directly — not ByteString | undocumented | 9/15 |
| GE-20260505-db8f1c | `git rebase --onto upstream/main <sha> branch` — drop a specific commit without interactive rebase | technique | 11/15 |
| GE-20260505-df6f1e | Sub-tile LOS sampling for path smoothing: step at 0.8× movement speed | technique | 11/15 |
| GE-20260505-ea8485 | `gh repo list --json isFork` returns `parent: null` for forks — field is unreliable for fork detection | gotcha | 8/15 |
| GE-20260505-ef9683 | PR branch silently carries unrelated commit when cut from local main ahead of upstream | gotcha | 11/15 |
| GE-20260505-f60bab | MCP StdioServerParameters command='python3' spawns wrong interpreter in pyenv/venv — McpError: Connection closed | gotcha | 12/15 |
| GE-20260505-f694a2 | sed inline header patch during cross-repo file copy — avoids copy-then-edit | technique | 8/15 |
| GE-20260506-01e78e | Playwright bounding_box() excludes CSS margins — margin-caused gaps invisible to bbox measurements | gotcha | 10/15 |
| GE-20260506-25d851 | Jekyll --incremental does not rebuild when layouts or includes change — only content files trigger rebuild | gotcha | 10/15 |
| GE-20260506-3096d9 | rustkyll serve does not support --incremental flag despite build supporting it | undocumented | 8/15 |
| GE-20260506-934502 | Two-pass Liquid sort for stable multi-key ordering: sort secondary first, then primary | technique | 10/15 |
| GE-20260508-a30558 | git rm -r silently leaves untracked files — only tracked files are staged for removal | gotcha | 10/15 |
| GE-20260510-cf4b9d | mvn -Dtest=ClassName -am fails on upstream modules that have no matching tests | gotcha | 11/15 |
| GE-20260511-044e40 | git rebase: `reword` silently becomes `pick` in non-interactive sessions | gotcha | 13/15 |
| GE-20260511-1b4fbc | git `squash` without GIT_EDITOR concatenates both commit messages and uses the first as subject | undocumented | 11/15 |
| GE-20260511-3495de | ide_find_class MCP tool returns kind:CLASS for interfaces — use get_symbol_info to confirm | gotcha | 9/15 |
| GE-20260511-3986e6 | `&&`-chained grep commands silently stop when any grep finds nothing (exit 1) | gotcha | 9/15 |
| GE-20260511-4e76ab | cc-praxis workspace hook false-negative — checks wrong CLAUDE.md for ## Session Start | gotcha | 9/15 |
| GE-20260511-88aede | IntelliJ build_project catches test-source compilation errors that Maven misreports as main-source failures | technique | 11/15 |
| GE-20260511-9c3c13 | Use `-F /tmp/msg.txt` not `-m "..."` for exec amends in non-interactive rebase — Unicode-safe and shell-escape-free | technique | 11/15 |
| GE-20260511-d8a359 | Check branch relationships in both directions — single-direction `git log A ^B` is ambiguous | technique | 12/15 |
| GE-20260511-db8f50 | git-squash on a fork+upstream repo silently operates on the stale fork, not the authoritative remote | gotcha | 9/15 |
| GE-20260512-0acffb | mvn validate verifies Maven reactor structure after directory renames without triggering compilation or IntelliJ cache | technique | 9/15 |
| GE-20260512-0dc5df | macOS sed -i '' silently empties a file when the working tree file is already empty | gotcha | 11/15 |
| GE-20260512-40d282 | IntelliJ build_project returns stale errors after Maven module directory renames until Maven is reimported | gotcha | 10/15 |
| GE-20260512-7f4aa4 | Use javap -verbose to inspect CDI/JPA annotations on dependency JAR classes without source access | technique | 9/15 |
| GE-20260512-8c282a | IntelliJ Move Package refactoring corrupts @Inject field declarations — merges annotation with next field's type name | gotcha | 12/15 |
| GE-20260512-a28ecc | Maven relative paths resolve to wrong worktree when shell cwd changes — use absolute paths | gotcha | 10/15 |
| GE-20260512-aa3873 | Orphaned git submodule entry without .gitmodules causes git rm -r to fail with 'could not lookup name' | gotcha | 10/15 |
| GE-20260512-deda31 | Use Python str.replace() over sed -i '' for safe multi-file text replacement on macOS | technique | 9/15 |
| GE-20260512-f3a464 | IntelliJ MCP ide_refactor_rename cannot do Move Package — only handles same-level renames | undocumented | 11/15 |
| GE-20260513-01e602 | Use 'git show <commit>:path > target' to recover file content from any point in git history without checkout | technique | 10/15 |
| GE-20260513-176ca1 | git mv fails with 'No such file or directory' when target directory doesn't exist — partially stages the deletion, data loss on follow-up git rm | gotcha | 10/15 |
| GE-20260513-3f8e53 | ide_find_references on an interface method confirms zero polymorphic callers — safe to remove | technique | 10/15 |
| GE-20260513-af85fa | publish-blog skill reads from docs/_posts/ but workspace blog entries live in blog/ — paths don't match | gotcha | 8/15 |
| GE-20260515-1f6274 | `mcp__intellij__search_file` requires `q` parameter — not `globPattern` like `find_files_by_glob` | gotcha | 9/15 |
| GE-20260516-42a11c | Git stash pop conflict markers inside a Java file cause 'cannot find symbol' for classes in the same package | gotcha | 11/15 |
| GE-20260516-4e5919 | Discovery test as permanent protocol constant coverage instrument | technique | 11/15 |
| GE-20260516-c6d441 | macOS sed -i '' silently wipes file when replacement pattern has no match | gotcha | 11/15 |
| GE-20260516-fba7b6 | git -C <path> is required in Claude Bash tool calls — cd state does not persist between calls | technique | 11/15 |
| GE-20260517-1ad615 | macOS keychain has GitHub credentials but git ignores them without credential.helper configured | gotcha | 10/15 |
| GE-20260517-3dddfa | Hortora garden pre-commit hook blocks all commits when untracked GE-*.md files exist | gotcha | 12/15 |
| GE-20260517-62b9db | Empty HTML <article> element causes html.parser to repeat surrounding content on re-serialisation | gotcha | 11/15 |
| GE-20260517-97d306 | shell mv + git add <newdir>/ leaves original tracked files as unstaged deletions | gotcha | 11/15 |
| GE-20260517-9d8cdf | Epic skill routes to close workflow only when on the epic branch — orphaned .meta on main has no close path | gotcha | 11/15 |
| GE-20260517-fc6be7 | JOURNAL.md plain prose is silently skipped at epic close — only §Section anchors are merged into DESIGN.md | gotcha | 12/15 |
| GE-20260521-fe44c0 | work-end skill silently targets the wrong repos when invoked from a different workspace session | gotcha | 10/15 |
| GE-20260521-d8d53f | Audit a stale issue table with a gh jq loop — O(N) issue state checks in one command | technique | 8/15 |
| GE-20260521-df2a10 | Python YAML frontmatter str.split('---') breaks when '---' appears in a quoted value | gotcha | 11/15 |
| GE-20260521-9bef0c | git rebase -i rejects pick on two-parent merge commits with 'invalid line' | gotcha | 10/15 |
| GE-20260521-753c20 | --rebase-merges squash conflicts on shared files when merge replays see squash-modified state | gotcha | 9/15 |
| GE-20260521-517bda | git rebase -i onto a backup/pre-squash branch immediately conflicts — backup is a sibling, not an ancestor | gotcha | 11/15 |
| GE-20260521-1d5032 | git rebase -i todo: 'pick' does not accept merge commits — use 'merge -C' or 'drop' | gotcha | 8/15 |
| GE-20260521-f4c128 | gh repo create defaults to SSH remote — fails silently on machines without SSH keys | gotcha | 9/15 |
| GE-20260522-ed1b72 | Protocol files written by cross-repo sessions accumulate silently as untracked | gotcha | 11/15 |
| GE-20260522-fee40e | Audit closed status of all branches without checkout using git show <branch>:path | technique | 10/15 |
| GE-20260522-cf54ad | `git branch --merged` silently misses squash-rebased branches — use `git log main --grep` to verify content | gotcha | 11/15 |
| GE-20260522-e062ba | Reordering commits in `git rebase -i` todo causes intermediate tree divergence — only final HEAD diff is authoritative | gotcha | 9/15 |
| GE-20260522-7159b4 | git log --oneline in pre-push hooks silently breaks ^-anchored grep patterns — SHA prefix defeats the anchor | gotcha | 11/15 |
| GE-20260522-5b1589 | git rebase -i with 'drop' on a merge commit exits 0 silently — rebase never runs | gotcha | 11/15 |
| GE-20260522-b341ae | GitHub transparently redirects git push after repo transfer — old origin URL still works | undocumented | 9/15 |
| GE-20260522-d6a1c9 | IntelliJ has three separate config files that must all be updated when a project repo is physically relocated | gotcha | 10/15 |
| GE-20260522-f8c1c3 | Workflow state dotfiles invisible to bare ls — design/.meta appears missing | gotcha | 8/15 |
| GE-20260522-76dc5b | Blog entries added to workspace main after branch creation are invisible from the epic branch | gotcha | 10/15 |
| GE-20260522-543863 | git checkout -b confirms success but repo silently reverts to main later in the same session | gotcha | 12/15 |
| GE-20260522-7c6ec7 | Bulk sed rename on markdown files garbles headers with parenthesized values | gotcha | 8/15 |
| GE-20260522-0d3a0d | git squash working branch shows stale commit range when main updated concurrently by another session | gotcha | 11/15 |
| GE-20260522-409183 | GIT_SEQUENCE_EDITOR rebase todo fails silently on SHA typo — generate from git log, not by hand | gotcha | 11/15 |
| GE-20260522-b9a6d4 | git push --force-with-lease always rejects on a freshly-created GitHub fork | gotcha | 10/15 |
| GE-20260523-5b3204 | git rebase -i: including a 'drop' for a merge commit in a custom todo causes BUG: sequencer.c unexpected todo_command | gotcha | 10/15 |
| GE-20260523-1b6250 | Build-order 'optionally' annotation does not register a cross-repo dep in the impact-analysis table | technique | 10/15 |
| GE-20260524-4bc41a | git filter-repo re-run fails with EOF when reading a line — delete .git/filter-repo/already_ran first | gotcha | 8/15 |
| GE-20260521-1d5032 | git rebase -i todo: 'pick' does not accept merge commits — use 'merge -C' or 'drop' | gotcha | 8/15 |
| GE-20260524-9ef9fa | GitHub Actions bash: missing associative map key returns empty string silently | gotcha | 9/15 |
| GE-20260524-e0aabf | Incremental CI: module missing from state-save step always rebuilds on next run | gotcha | 9/15 |
| GE-20260524-7de5c2 | git rebase -i exec commands cannot span multiple lines — parser treats each line as a separate command | gotcha | 9/15 |
| GE-20260524-2920b6 | SVG orient=auto marker path must point right (+x direction) not in the arrow's visual direction | gotcha | 8/15 |
| GE-20260524-2920b6 | SVG orient=auto marker path must point right (+x direction) not in the arrow's visual direction | gotcha | 8/15 |
| GE-20260524-1f0045 | git push <remote> <branch> from non-main branch silently pushes local <branch>, not current branch | gotcha | 10/15 |
| GE-20260524-c66b05 | Tutorial layer dependency labels can silently point at the wrong milestone | gotcha | 9/15 |
| GE-20260524-bc8f10 | git commit --amend without --allow-empty silently skips empty commits | gotcha | 13/15 |
| GE-20260524-ce0ad3 | git diff --name-only main..branch counts main's newer files as missing from old branches | gotcha | 9/15 |
| GE-20260524-8ba4ce | Piping Playwright output through `head -N` hangs the test process indefinitely | gotcha | 10/15 |
| GE-20260524-4c1400 | Verify browser-side JavaScript fixes in plain Node.js using diagnostic token data — no app launch needed | technique | 11/15 |
| GE-20260525-8e5b29 | git log branch ^main returns commits that are already on main when branch pointer is stale post-rebase | gotcha | 11/15 |
| GE-20260525-06327c | Setting core.hooksPath before committing the hook causes the hook to block its own installation commit | gotcha | 10/15 |
| GE-20260525-c0b5a4 | Write bulk git operations to /tmp/script.py to avoid shell permission-prompt triggers in Claude Code | technique | 10/15 |
| GE-20260525-db848c | Claude Code plugin hooks/hooks.json supports ${CLAUDE_PLUGIN_ROOT} for portable hook script paths | undocumented | 10/15 |
| GE-20260525-2833e9 | GitHub Actions dispatch chain does not mirror the dependency graph — always verify from workflow files | gotcha | 10/15 |
| GE-20260525-5cf881 | OpenClaw pluggable context engine — kind:context-engine delegates full context assembly to a plugin | undocumented | 10/15 |
| GE-20260525-a91e15 | OpenClaw /hooks/agent deliver:webhook — POSTs finished agent result to arbitrary HTTP URL | undocumented | 11/15 |
