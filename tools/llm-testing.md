# LLM / Claude CLI — Gotchas and Techniques

Non-obvious approaches for testing systems that use LLM tool calls (MCP, function calling, etc.).

---

## Assert on side effects, not LLM output, when testing AI tool use

**Stack:** Any LLM with tool calling (Claude, OpenAI, etc.), any testing framework
**Labels:** `#strategy` `#testing` `#llm-testing`
**What it achieves:** Deterministic automated tests for systems where an LLM calls tools, regardless of how the LLM phrases its response.
**Context:** Testing a system where an LLM calls tools (MCP, function calling, etc.) and you want to verify the tools worked — but the LLM's text response changes between runs.

### The technique
Ignore the LLM's response text entirely. Assert exclusively on what the tools *did* to the system — database state, files created, processes started, API calls made. These are deterministic regardless of model response wording.

```java
// ❌ WRONG — fragile, breaks when model wording changes
assertThat(claudeOutput).contains("I've created a session called");

// ✅ RIGHT — deterministic, model-agnostic
var sessionExists = new ProcessBuilder("tmux", "has-session", "-t", "remotecc-e2e-test")
    .start().waitFor() == 0;
assertTrue(sessionExists, "tmux session should exist after Claude created it");
```

### Why this is non-obvious
Testing LLM systems feels like testing the LLM's output. But tool calls are the actual contract between the LLM and the system. If the tool was called with the right arguments, the effect happened — the LLM's narrative is irrelevant to correctness.

### When to use it
Any project with LLM tool use — MCP servers, OpenAI function calling, Anthropic tool_use, LangChain agents.

---

## Use real LLM invocations as protocol capture, replace with scripted replay for CI

**Stack:** Claude Code CLI, any LLM, JUnit 5 / any test framework
**Labels:** `#strategy` `#testing` `#llm-testing` `#ci-cd`
**What it achieves:** Bootstrap tests with real LLM calls to discover what the model actually does, then replace with deterministic scripted sequences for CI — fast, free, no API tokens.
**Context:** Testing MCP servers or any LLM tool-call system where you want CI that doesn't call real LLMs.

### The technique
1. Run the test once with a real LLM invocation, capturing the tool call sequence (JSON-RPC messages, MCP calls, etc.)
2. Save the sequence as a scripted replay: a test that sends the same JSON-RPC messages directly without an LLM
3. CI runs the scripted replay — deterministic, fast, no API cost
4. Re-run the real LLM test only when the MCP interface changes (new tool, renamed argument, updated description)

### Why this is non-obvious
The instinct is to either test with real LLM calls (slow, expensive, non-deterministic) or mock at the HTTP level (doesn't test the actual protocol). Protocol capture + replay gets determinism without mocking — you're testing the same message sequence the LLM actually uses.

---

## Use claude `--mcp-config` + `--strict-mcp-config` to test MCP servers in isolation

**Stack:** Claude Code CLI (`claude`), MCP HTTP transport, JUnit 5, Maven
**Labels:** `#testing` `#llm-testing` `#mcp-server` `#claude-cli`
**What it achieves:** E2E tests that invoke the real `claude` CLI against a locally-running MCP server, without modifying global claude config or requiring persistent external processes.
**Context:** Projects implementing an MCP server that want to validate the full MCP handshake (initialize → tools/list → tools/call) with a real LLM client.

### The technique

```bash
# --mcp-config format: same mcpServers wrapper as settings.json
cat > /tmp/test-mcp.json << 'MEOF'
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "http://localhost:8081/mcp"
    }
  }
}
MEOF

claude \
  --mcp-config /tmp/test-mcp.json \
  --strict-mcp-config \
  --dangerously-skip-permissions \
  -p "List the tools from the my-server MCP server"
```

In Java (JUnit 5 + Quarkus):

```java
@QuarkusTest
@EnabledIf("claudeIsAvailable")   // NOT @EnabledIfEnvironmentVariable — claude uses keychain OAuth
class ClaudeE2ETest {

    static boolean claudeIsAvailable() {
        try { return new ProcessBuilder("claude", "--version")
            .redirectErrorStream(true).start().waitFor() == 0;
        } catch (Exception e) { return false; }
    }

    private static Path mcpConfigFile;

    @BeforeAll
    static void setup() throws Exception {
        mcpConfigFile = Files.createTempFile("mcp-test-", ".json");
        // mcpServers wrapper required — same schema as settings.json
        Files.writeString(mcpConfigFile,
            "{\"mcpServers\":{\"my-server\":{\"type\":\"http\",\"url\":\"http://localhost:8081/mcp\"}}}");
    }

    @AfterAll
    static void teardown() throws Exception { Files.deleteIfExists(mcpConfigFile); }

    @Test
    void claudeCanUseTools() throws Exception {
        var pb = new ProcessBuilder(
            "claude", "--mcp-config", mcpConfigFile.toString(),
            "--strict-mcp-config", "--dangerously-skip-permissions",
            "-p", "Create a session called e2e-test in /tmp")
            .redirectErrorStream(true);
        var process = pb.start();
        process.getInputStream().transferTo(OutputStream.nullOutputStream());
        int exit = process.waitFor(120, TimeUnit.SECONDS) ? process.exitValue() : -1;
        assertEquals(0, exit);

        // Assert on side effect — not Claude's text output
        assertTrue(new ProcessBuilder("tmux", "has-session", "-t", "remotecc-e2e-test")
            .start().waitFor() == 0);
    }
}
```

### Three non-obvious details
1. **`--mcp-config` uses the same `mcpServers` wrapper as `settings.json`** — the schema is identical. Some MCP plugin examples omit the wrapper; passing the wrong format produces `"Invalid MCP configuration: mcpServers: Does not adhere to MCP server configuration schema"` with no hint about what's wrong.
2. **`--strict-mcp-config`** ignores global config entirely — true isolation. Without it, global servers also load and Claude may call the wrong one.
3. **Assert on side effects, not Claude's text** — Claude's wording is non-deterministic. Test what the tool *did* to system state.

### When to use it
- Validating MCP tool schemas and descriptions are usable by the LLM
- Pre-release gate when the MCP interface changes
- NOT for CI every commit — too slow, costs API tokens. Use scripted replay for CI.

---

## `claude` CLI subprocess uses keychain OAuth — ANTHROPIC_API_KEY not required on dev machines

**Stack:** Claude Code CLI (`claude`), JUnit 5, any test harness that shells out to `claude`
**Symptom:** Tests guarded by `@EnabledIfEnvironmentVariable(named = "ANTHROPIC_API_KEY", ...)` skip silently in the developer's own environment even though `claude` is fully authenticated and works interactively. 0 tests run, 2 skipped, no error.
**Context:** Automated tests that invoke `claude` as a subprocess. Dev has authenticated via `claude login` (macOS keychain OAuth); CI uses API key.

### What was tried (didn't work)
- `@EnabledIfEnvironmentVariable(named = "ANTHROPIC_API_KEY", matches = ".+")` — tests skip because env var isn't set, even though `claude -p "say ok"` works fine from the same shell

### Root cause
`claude` uses macOS keychain OAuth when authenticated via `claude login`. `ANTHROPIC_API_KEY` is only required for API-key-based auth (CI environments, `--bare` mode). Subprocess invocations inherit keychain access without any env var.

### Fix

Check for `claude` availability instead of `ANTHROPIC_API_KEY`:

```java
// ❌ Wrong — skips when user is auth'd via keychain (common on dev machines)
@EnabledIfEnvironmentVariable(named = "ANTHROPIC_API_KEY", matches = ".+")
class ClaudeE2ETest { ... }

// ✅ Correct — skips only when claude binary is absent or broken
@EnabledIf("claudeIsAvailable")
class ClaudeE2ETest {
    static boolean claudeIsAvailable() {
        try {
            return new ProcessBuilder("claude", "--version")
                .redirectErrorStream(true).start().waitFor() == 0;
        } catch (Exception e) { return false; }
    }
}
```

For subprocess invocation — let `claude` use whichever auth it has:

```java
var pb = new ProcessBuilder("claude", "--dangerously-skip-permissions", "-p", prompt);
// Forward API key only if set; claude uses keychain auth otherwise
var apiKey = System.getenv("ANTHROPIC_API_KEY");
if (apiKey != null) pb.environment().put("ANTHROPIC_API_KEY", apiKey);
```

### Why this is non-obvious
`ANTHROPIC_API_KEY` is the standard pattern in every Claude API example. The failure is silent skipping (not an error) — test suite reports success and you only notice if you check the skipped count. The keychain auth path is not mentioned in `claude -p` documentation.

---

## Use a second Claude to verify the first Claude's work — and always confirm the absolute file path

**ID:** GE-0003
**Stack:** Claude Code CLI (any version)
**Labels:** `#strategy` `#multi-agent` `#llm-testing`
**What it achieves:** Catches errors, omissions, and hallucinations in Claude's output by having an independent Claude instance check the result — with a critical trust-but-verify step on file identity.
**Context:** Any time one Claude session produces output (writes code, edits a document, makes changes to a file) and you want confidence it's correct before proceeding.

### The technique

After Claude A makes changes, ask Claude B to verify them. Then ask Claude A to re-check Claude B's verification.

The critical step: **before trusting any disagreement or agreement, ask both Claudes the same question:**

> "What is the absolute path to the file you are reading?"

Without this, two Claudes can be confidently disagreeing about two entirely different files — one reading a copy, a cached version, or a file at a similar path. The disagreement looks like a factual dispute when it's actually a path mismatch.

### Why this is non-obvious

The natural assumption is that both Claudes are reading the same file if you give them the same filename. But in multi-workspace or multi-project setups, the same filename can exist at different absolute paths. A Claude working in one context resolves relative paths differently from one working in another. Neither Claude flags the discrepancy — they both believe they're reading the right file.

### Workflow
1. Claude A makes changes
2. Give Claude A's output (or the changed file path) to Claude B
3. Ask Claude B to verify specific claims ("does the file now contain X?")
4. If Claude B disagrees: ask both "what is the absolute path to the file you are reading?"
5. If paths differ: resolve the path issue first — the content disagreement is probably spurious
6. If paths match: the disagreement is real; ask Claude B to quote the specific lines it's basing its answer on

**See also:** GE-0012 for using git commit hash as the authoritative arbiter when disagreement persists.

*Score: 11/15 · Included because: path-confirmation insight is genuinely discovered only by running into the phantom disagreement; not documented anywhere · Reservation: may date poorly as Claude's context-handling evolves*

---

## Commit messages describe intent, not content — Claude can be confidently wrong about file state

**ID:** GE-0011
**Stack:** Claude Code CLI (any version), git
**Symptom:** Claude reports that content exists in a file, citing a relevant-sounding commit message as evidence. The file does not contain the claimed content. Claude shows no uncertainty.
**Context:** Any time Claude is asked to verify that past work was completed, especially work done in a previous session or by a different Claude instance.

### What was tried (didn't work)
- Read `git log --oneline` — saw commit messages like "feat: add project blog structure and update AI collaboration voice"
- Treated the commit message names as proof the content had landed
- Reported to the user: "Yes, those additions were made" — this was wrong

### Root cause
Commit messages are author-written summaries of intent. They do not guarantee that specific content landed in a specific file. Claude pattern-matches on keywords in commit messages ("add", "feat", "refactor") and interprets a plausible-sounding message as confirmation. The actual file is never read — only the log.

A commit message like "feat: add common register mistakes" proves a commit exists with that description. It does not prove the content is in the file it claims to modify, in the form described, with the specific sections mentioned.

### Fix
Always read the actual file to verify content — never the git log alone.

```bash
# Read current file state
cat <filepath>

# Or read file at a specific commit
git show HEAD:<filepath>
git show <hash>:<filepath>
```

If verifying that a specific section exists: `grep -n "section title" <filepath>`.
If verifying that specific content was added: `git diff <before-hash> <after-hash> -- <filepath>` shows exactly what changed.

### Why this is non-obvious
The instinct is to trust a descriptive commit message as proof. A commit exists, the message matches the claimed work, the author is credible — of course the content is there. But the message is a human summary, not a content hash. Claude has no way to know without reading the file — but the confidence signal from a matching commit message suppresses the doubt that would trigger a file read.

*Score: 13/15 · Included because: naming it explicitly prevents a class of confident errors; the failure is invisible — Claude doesn't signal doubt, user has no reason to question it · Reservation: "trust but verify" is well-known; the LLM-specific failure mode is the less-obvious part*

---

## Use git commit hash as authoritative arbiter when multiple Claude instances disagree about file state

**ID:** GE-0012
**Stack:** Claude Code CLI (any version), git
**Labels:** `#strategy` `#llm-testing` `#multi-agent`
**What it achieves:** A verifiable, session-independent resolution to conflicting claims about file state between Claude instances — neither instance's memory or confidence is trusted, only the hash.
**Context:** Multi-Claude workflows where different sessions have worked on the same files and now disagree about what the current content is.

### The technique

When two Claude instances disagree about whether content exists in a file, don't ask one of them to re-read it or trust the more confident one. Instead, point both at a specific commit hash:

```bash
# Show exact file content at a specific commit — same answer for any Claude
git show <hash>:<filepath>

# Show what changed between two commits
git diff <before-hash> <after-hash> -- <filepath>

# Find the commit where content was supposed to be added
git log --oneline -- <filepath>
# Then inspect: git show <hash>:<filepath> | grep "section title"
```

Both Claude instances can run the same command and get the identical answer. The hash is immutable — it cannot be misremembered or affected by context window differences.

To report resolution to the user:
> "Verified at commit `abc1234`: the section [is / is not] present. Here's the relevant excerpt: [quote from git show output]."

### Why this is non-obvious

The instinct when two Claudes disagree is to:
- Ask one of them to re-read the file (they've already read it and reached different conclusions — re-reading may reproduce the same error)
- Trust the more recent or more confident instance (confidence is not correlated with accuracy)
- Trust the instance that "did the work" (that instance may have a stale or incorrect view)

The insight is that git history is the only source of truth both instances can query independently without relying on each other's context. A commit hash is specific and immutable — it eliminates the "who do you trust?" problem entirely.

**See also:** GE-0003 for the two-Claude verification workflow, and GE-0011 for why commit messages alone are not sufficient.

*Score: 14/15 · Included because: multi-Claude workflows are becoming common; the git hash as authoritative arbiter is not the natural move · Reservation: none identified*
