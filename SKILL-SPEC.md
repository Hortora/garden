# Skill Specification: knowledge-garden

**For:** Skills Claude — use this document to create the `knowledge-garden` skill.

---

## What this skill does

Captures non-obvious technical bugs, weird behaviours, and things that silently don't work — and adds them to a central knowledge garden so future Claude instances don't have to rediscover them.

**This skill is NOT for:**
- General "how to" or tutorial content
- Expected errors with documented fixes
- Things that are hard because they're complex (hard is fine; *non-obvious* is the filter)

**This skill IS for:**
- Things that silently fail with no error or warning
- Behaviours that contradict what the documentation says
- Fixes that are surprising — where the obvious approach doesn't work and the real fix is unexpected
- Hard-to-identify bugs where the symptom misleads about the cause
- Hard-to-fix bugs where everything tried looks like it should work
- Obscure, random, or context-specific behaviours

---

## Knowledge garden location

```
/Users/mdproctor/claude/knowledge-garden/
├── README.md
├── macos-native-appkit/
│   └── appkit-panama-ffm.md
├── graalvm-native-image/
├── java-panama-ffm/
│   └── native-image-patterns.md
└── quarkus/
```

This is a git repo. The skill must commit after adding an entry.

---

## Trigger conditions

Invoke this skill when:
- A debugging session concludes and something non-obvious was discovered
- The user says "add this to the knowledge garden", "log this weird behaviour", "this should go in the garden"
- A fix is found where the documented approach didn't work
- Something works in one context (e.g. JVM mode) but silently fails in another (e.g. native image) with no error
- Multiple things were tried before the fix was found — meaning future Claude would likely repeat the same failed attempts

Do NOT invoke for:
- Routine bugs with straightforward fixes
- Things that are hard because they're genuinely complex (architecture, design trade-offs)
- How-to guides or explanations of how something works

---

## Skill workflow

### Step 1: Confirm this is garden-worthy

Ask yourself: would a skilled developer be surprised by this? Did multiple reasonable approaches fail before the fix was found? Is the symptom misleading about the cause? If yes to any — proceed.

If unclear, ask the user: "Is this worth adding to the knowledge garden? It would go under [category] as '[short title]'."

### Step 2: Extract the entry

From the conversation, code, and context, extract:

1. **Title** — short, specific, describes the weird thing (not the fix). Examples:
   - ✅ "GCD main queue blocks silently never execute when [NSApp run] is inside dispatch_async"
   - ✅ "Arena.ofAuto() throws on close()"
   - ❌ "How to update NSTextView" (that's a tutorial)
   - ❌ "NSTextField focus issue" (too vague)

2. **Stack** — technology tags. Be specific. Examples: `AppKit, GCD, Objective-C` / `Panama FFM, jextract, GraalVM 25` / `Quarkus Native, GraalVM`

3. **Symptom** — what the developer *observes*. Focus on the misleading part. "No error is reported" is important context.

4. **Context** — when/where this applies. What setup triggers it.

5. **What was tried (didn't work)** — bulleted list. Include the outcome of each attempt. This is critical — it's what prevents future Claude from repeating the same failed approaches.

6. **Root cause** — what was actually happening. One clear explanation.

7. **Fix** — code or config. Be specific. Include what NOT to do alongside what works.

8. **Why this is non-obvious** — the insight. What makes this a gotcha rather than just a bug? Why would a skilled developer be misled?

### Step 3: Determine the file

Map the stack tags to the knowledge garden directory:

| Technology | Directory | File |
|-----------|-----------|------|
| AppKit, NSTextField, NSSplitView, WKWebView, NSWindow | `macos-native-appkit/` | `appkit-panama-ffm.md` (or create new file if different context) |
| Panama FFM, jextract, upcalls, downcalls | `java-panama-ffm/` | `native-image-patterns.md` |
| GraalVM native image, reflect-config, reachability-metadata | `graalvm-native-image/` or `java-panama-ffm/` | existing or new file |
| Quarkus | `quarkus/` | create file if needed, e.g. `quarkus-native.md` |
| Cross-cutting / doesn't fit | Create a new directory with a descriptive name | |

If no existing file fits, create a new one with a descriptive kebab-case name.

### Step 4: Format and append

Append the entry to the target file using this exact format:

```markdown
---

## [Title]

**Stack:** [comma-separated tags]
**Symptom:** [what you observe — the misleading part]
**Context:** [when/where this applies]

### What was tried (didn't work)
- tried X — result
- tried Y — result

### Root cause
[what was actually happening]

### Fix
[code block or config — be specific]

### Why this is non-obvious
[the insight]
```

The `---` separator before `##` keeps entries visually distinct.

### Step 5: Commit

```bash
cd /Users/mdproctor/claude/knowledge-garden
git add .
git commit -m "feat([directory]): add '[short title of entry]'"
```

Example commit messages:
- `feat(macos-native-appkit): add 'WKWebView silent failure in JVM process'`
- `feat(java-panama-ffm): add 'Arena.ofAuto() throws on close()'`

### Step 6: Report back

Tell the user:
- What was added and where
- The one-sentence summary of the entry
- Whether a new file was created

---

## Entry quality checklist

Before committing, verify:

- [ ] Title describes the *weird thing*, not the fix
- [ ] "What was tried" includes at least the things actually attempted in the session
- [ ] Root cause explains WHY, not just WHAT
- [ ] Fix has actual code or config (not "use X instead")
- [ ] "Why non-obvious" answers: why would a skilled developer be surprised?
- [ ] Stack tags are specific enough to be searchable

---

## Example entries (reference)

See existing files for the expected style:
- `/Users/mdproctor/claude/knowledge-garden/macos-native-appkit/appkit-panama-ffm.md`
- `/Users/mdproctor/claude/knowledge-garden/java-panama-ffm/native-image-patterns.md`

The GCD serialisation entry is a good model — it has a clear symptom, multiple failed approaches, a non-obvious root cause, and a fix that uses a completely different mechanism than what was tried.

---

## Skill invocation examples

User says these → invoke skill:
- "Add this to the knowledge garden"
- "This should be documented somewhere"
- "Log this weird behaviour"
- "We just discovered something non-obvious"
- "This took way too long to find"
- "Future Claude should know about this"

User says these → do NOT invoke:
- "How does X work?"
- "Explain Y"
- "That was a complex bug" (complex ≠ non-obvious)
