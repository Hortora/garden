# Hortora Distribution — Validated Implementation Design

**Date:** 2026-08-04
**Status:** Validated — ready for implementation planning
**Source spec:** Designed in engine session (`docs/specs/2026-08-04-hortora-distribution-design.md` in soredium clone)

---

## Summary

This design validates the original distribution spec against the garden repo's
current state and captures all decisions, corrections, and gap resolutions from
the brainstorming session. It covers three components:

1. **Installer** (`scripts/hortora-setup.sh`) — monolithic idempotent bash script
2. **Contributor pipeline** — staging branch, evolved CI workflows, post-commit hook
3. **Auto-update service** — daily timer with change-detection rebuild

---

## Spec Corrections

Issues found during validation that differ from the original spec:

| Spec Claim | Reality | Resolution |
|---|---|---|
| ONNX models ~90MB total | BGE-M3: 2.1GB, reranker: 88MB, SPLADE: 508MB = ~2.7GB | Corrected in design. Model download step reflects actual sizes. |
| Models hosted as GitHub Release assets | No releases exist on Hortora/engine. Models produced by local Python export. | Prerequisite gate: installer implements download against expected URLs. Engine must publish assets first. |
| `download-models.sh` downloads models | It's a verifier, not a downloader | Installer implements its own download logic against Release asset URLs |
| `validate-submissions.yml` (new workflow) | `validate-on-pr.yml` already exists with 70% of needed functionality | Evolve existing workflow instead of creating new file |
| No Python required | `claude-skill sync-local` requires python3 | python3 treated as soft dependency — warn if missing |
| Prerequisites: git, Java 25+ | Post-commit hook needs `gh` CLI for PR creation | `gh` treated as soft dependency — push works without it, PR creation degrades gracefully |
| `validate-on-pr.yml` GE-ID regex | Only matches legacy `GE-NNNN.md`, not current `GE-YYYYMMDD-XXXXXX.md` | Fix regex in evolved workflow |

---

## Prerequisites (engine-side, not implemented here)

Before the installer can fully function:

1. **Publish ONNX model assets** as GitHub Release on `Hortora/engine`
   - BGE-M3: `model.onnx` (3MB) + `model.onnx.data` (2.1GB) + `tokenizer.json` (16MB)
   - Reranker: `model.onnx` (87MB) + `tokenizer.json` (695KB)
   - SPLADE: `model.onnx` (507MB) + `tokenizer.json` (695KB)
   - Include `checksums.sha256` in release assets

---

## Component 1: Installer (`scripts/hortora-setup.sh`)

Single idempotent bash script (~400-500 lines). Each step checks if work is
already done before acting. Safe to re-run.

### Function structure

```
main()
  detect_platform()          → sets ARCH, OS, QDRANT_ASSET
  check_prerequisites()      → git, java 25+
  install_qdrant()           → download binary, write config, install service
  clone_or_link_repos()      → engine, grove, soredium (detect existing, symlink or clone)
  download_models()          → from GitHub Release assets (prerequisite gate)
  build_apps()               → mvnw package for engine + grove
  install_services()         → launchd plists or systemd units (see model gate below)
  install_skills()           → python3 claude-skill sync-local (soft dep)
  configure_claude_code()    → jq merge MCP server into ~/.claude/settings.json
  setup_contributor()        → create submissions branch, install post-commit hook
  verify_installation()      → health checks on all ports
```

### Platform detection

```
macOS aarch64  → qdrant-aarch64-apple-darwin.tar.gz
Linux x86_64   → qdrant-x86_64-unknown-linux-musl.tar.gz
Linux aarch64  → qdrant-aarch64-unknown-linux-musl.tar.gz
```

### Git protocol detection

Reads the remote URL of `~/.hortora/garden` to determine SSH vs HTTPS:
- `git@github.com:Hortora/...` → SSH for all clones
- `https://github.com/Hortora/...` → HTTPS for all clones

### Existing clone detection

Before cloning, check for existing repos at `~/claude/hortora/{engine,grove,soredium}`.
If found, symlink to `~/.hortora/{engine,grove,soredium}` instead of cloning.
This avoids dual installations and respects the developer's existing workspace.

```
if ~/claude/hortora/engine exists and has .git:
  ln -s ~/claude/hortora/engine ~/.hortora/engine
else:
  git clone <protocol>://github.com/Hortora/engine ~/.hortora/engine
```

### Idempotency patterns

- **Binary installs:** check if binary exists and is executable
- **Repo clones:** check if directory exists with valid `.git`
- **Service installs:** check if plist/unit file exists
- **Hook installs:** sentinel-guarded append (GE-20260422-8d2613)
- **Config merges:** check if MCP server entry already present in settings.json

### Heredoc discipline

Two modes, chosen per file type (GE-20260422-2afcb2):

- **Hooks and runtime scripts:** quoted heredoc (`<< 'EOF'`) — variables
  like `$HOME` and `$BRANCH` expand when the script runs, not when the
  installer writes it.
- **Launchd plists, Qdrant config, systemd units:** unquoted heredoc
  (`<< EOF`) — paths like `$HOME` must be expanded at install time because
  launchd/systemd/Qdrant don't expand shell variables in config files.

### Soft dependencies

| Dependency | Used for | If missing |
|---|---|---|
| python3 | `claude-skill sync-local` | Log warning, print manual instructions |
| gh | PR creation in post-commit hook | Push works, PR creation skipped with warning |

### Hard dependencies (beyond spec)

| Dependency | Used for | Install |
|---|---|---|
| jq | MCP server config merge into `~/.claude/settings.json` | `brew install jq` (macOS) / `apt install jq` (Linux) |

### Model gate — preventing engine crash loop

If `download_models()` fails (Release assets not published yet), the
installer:
1. Installs the engine plist/unit but does NOT load/enable it
2. Prints: "Engine service installed but not started — models not available.
   Run `hortora-setup.sh` again after models are published."
3. Qdrant and grove services start normally (they don't need models)
4. On re-run, if models are now present, loads the engine service

This prevents the engine from entering a KeepAlive crash loop trying to
load ONNX models that don't exist.

### Verify installation — retry with backoff

`verify_installation()` checks health endpoints with retry:
- Poll each port (6333, 8080, 8090) up to 30s with 5s intervals
- Services need startup time — Qdrant typically takes 2-5s, engine 10-25s
- Report per-service status: started / not started (with reason)
- Skip engine health check if engine service wasn't started (model gate)

### Prerequisites check

```bash
# Hard requirements — installer exits if missing
git --version
java -version  # must be 25+
command -v jq  # needed for settings.json merge

# Soft — warn and continue
command -v python3
command -v gh
```

---

## Component 2: Contributor Pipeline

### Branch model

```
main                    ← curator-approved content
  └── staging           ← CI-validated submissions (auto-merged)
        └── PR from submissions/alice
        └── PR from submissions/bob
```

### Post-commit hook

Installed by `setup_contributor()` via sentinel-guarded append to
`.git/hooks/post-commit`. Coexists with existing pre-commit, post-checkout,
pre-push hooks.

```bash
# hortora: contributor auto-push
# Only fires when the commit contains GE-* entry files and we're not on main
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "staging" ]; then
  exit 0
fi
CHANGED=$(git diff-tree --no-commit-id --name-only -r HEAD | grep -E '/GE-[0-9a-f-]+\.md$')
if [ -z "$CHANGED" ]; then
  exit 0
fi
USERNAME=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
if [ -z "$USERNAME" ]; then
  echo "hortora: git user.name not set — skipping auto-push"
  exit 0
fi
BRANCH="submissions/$USERNAME"
git push origin "HEAD:$BRANCH" 2>/dev/null || true
if command -v gh >/dev/null 2>&1; then
  OPEN=$(gh pr list --head "$BRANCH" --base staging --json number --jq length 2>/dev/null)
  if [ "$OPEN" = "0" ]; then
    gh pr create --head "$BRANCH" --base staging \
      --title "[$USERNAME] garden submissions" \
      --body "Auto-created by hortora-setup" 2>/dev/null || true
  fi
fi
```

**Guards:**
- Skips if on `main` or `staging` (prevents dedup sweep commits from triggering)
- Skips if the commit contains no GE-* files (only garden entries trigger push)
- Sanitizes username: strips characters invalid in git branch names
- Exits silently if `git config user.name` is unset

### Evolved `validate-on-pr.yml`

Changes to existing workflow:

1. **Fix GE-ID regex:** `'^[^/]+/GE-[0-9a-f-]+\.md$'` (matches both formats)
2. **Add dedup check step:** runs `scripts/dedup_check.py` against main's garden.db
3. **Add auto-merge step:** when target is `staging` AND label is `validated`, merge the PR.
   Labels are applied only by the CI workflow via `GITHUB_TOKEN` — contributors
   cannot add `validated` directly (GitHub restricts label modification to repo
   collaborators and workflows)
4. **Add auto-flush:** at 25+ validated entries, add `ready-for-review` label + summary comment
5. **Conditional behavior:** PRs targeting `main` keep current behavior (no auto-merge)

### `integrate-on-merge.yml`

Requires one change: the curator promotes staging→main via a **PR** (not a
direct merge), so the existing `on: pull_request: types: [closed]` trigger
fires. The PR title should indicate it's a promotion batch. The workflow
already handles multiple entry files per merge.

No other changes needed — the existing label check (`garden-submission`),
entry detection, and integration logic all work as-is. The curator adds the
`garden-submission` label to the promotion PR before merging.

### Curator promotion flow

```
1. Curator creates PR: staging → main
2. Curator adds `garden-submission` label
3. Curator merges PR
4. integrate-on-merge.yml fires → runs integrate_entry.py for each file
5. Pushes index updates to main
```

### New: `scripts/dedup_check.py`

- Checks out garden.db from main branch (`git show main:garden.db > /tmp/...`)
- **If garden.db doesn't exist on main** (fresh garden), skip dedup check
  and exit 0 — no false positives on empty corpus
- Compares new/changed GE files against existing entries
- Jaccard similarity on titles + tags, threshold 0.8
- Output: `{duplicates: [{new: "GE-X", existing: "GE-Y", similarity: 0.92}]}`
- Exit code 1 if any duplicate found above threshold
- Used by CI workflow, not by end users

---

## Component 3: Auto-update Service

### Script: `scripts/hortora-update.sh`

Standalone script invoked by the daily timer. Can also be run manually.

```
1. git -C ~/.hortora/garden   fetch origin main:main  (safe on any branch)
2. git -C ~/.hortora/engine   pull --ff-only
3. git -C ~/.hortora/grove    pull --ff-only
4. git -C ~/.hortora/soredium pull --ff-only
5. If engine SHA changed  → ./mvnw package -DskipTests -q → restart engine
6. If grove SHA changed   → ./mvnw package -DskipTests -q → restart grove
7. If soredium SHA changed → python3 scripts/claude-skill sync-local --all -y
```

**Garden uses `fetch origin main:main`** instead of `pull --ff-only` because
contributors may be on a `submissions/<username>` branch. `fetch main:main`
updates the local main ref without affecting the working tree or current branch.
Engine, grove, and soredium are always on main, so `pull --ff-only` is safe.

### Change detection

Compare `git rev-parse HEAD` before and after `git pull --ff-only`. If SHA
changed, rebuild/restart. No file-level diffing needed.

### Service restart

- macOS: `launchctl kickstart -k gui/$(id -u)/io.hortora.engine`
- Linux: `systemctl --user restart io.hortora.engine`

### Failure handling

- `git pull --ff-only` fails (diverged): log error, skip that repo
- Build fails: log error, don't restart (leave running version intact)
- No silent failures — every action timestamped in log

### Logging

Appends to `~/.hortora/logs/hortora-update.log`. Rotates at 1MB, keeps 5
(same pattern as existing `garden-agent.sh`).

---

## Component 4: Service Definitions

### macOS — launchd plists

Location: `~/Library/LaunchAgents/` (user-level, no sudo required)

| Plist | Runs | Lifecycle |
|---|---|---|
| `io.hortora.qdrant.plist` | `~/.hortora/qdrant/qdrant --config-path ~/.hortora/qdrant/config.yaml` | KeepAlive, RunAtLoad |
| `io.hortora.engine.plist` | `java -jar ~/.hortora/engine/target/quarkus-app/quarkus-run.jar` | KeepAlive, RunAtLoad |
| `io.hortora.grove.plist` | `java -jar ~/.hortora/grove/target/quarkus-app/quarkus-run.jar` | KeepAlive, RunAtLoad |
| `io.hortora.update.plist` | `~/.hortora/garden/scripts/hortora-update.sh` | CalendarInterval {Hour: 3} |

No service ordering — engine handles Qdrant startup races internally via
`waitForQdrant` readiness probe (GE-20260802-9f1ff0, fix deployed in
`CollectionMigration.java:120`).

Environment variables set per plist:
- `JAVA_HOME` (detected at install time)
- `HORTORA_HOME=$HOME/.hortora`
- Model paths, Qdrant URL, etc.

Logs: `StandardOutPath` / `StandardErrorPath` → `~/.hortora/logs/<label>.log`

### Linux — systemd units

Location: `~/.config/systemd/user/` (user-level, no sudo required)

Same structure as launchd. `Restart=always` for persistent services.
Timer unit with `OnCalendar=*-*-* 03:00:00` for updates. Enabled via
`systemctl --user enable --now <unit>`.

### Qdrant config

Generated at `~/.hortora/qdrant/config.yaml`:

```yaml
storage:
  storage_path: /Users/<username>/.hortora/qdrant/storage
service:
  grpc_port: 6334
  http_port: 6333
```

Absolute paths (no `~` expansion — Qdrant doesn't expand them).

---

## Design review fixes (post light review)

Issues resolved from coherence/structure/robustness/cross-cutting review:

| # | Issue | Fix |
|---|---|---|
| 1 | Post-commit hook fires on all commits including dedup sweeps | Guard: skip on main/staging, skip if no GE-* files in commit |
| 2 | `integrate-on-merge.yml` won't fire on staging→main direct merge | Curator promotes via PR (not direct merge), so existing trigger fires |
| 3 | Engine crash loop when models unavailable on fresh install | Model gate: install plist but don't load service until models verified |
| 4 | Clone path conflict `~/.hortora/engine` vs `~/claude/hortora/engine` | Detect existing clones, symlink instead of re-cloning |
| 5 | Auto-update `git pull` fails on contributor's submissions branch | Garden uses `fetch origin main:main` instead of `pull --ff-only` |
| 6 | Quoted heredocs wrong for plists (need install-time expansion) | Two modes: quoted for hooks, unquoted for plists/configs |
| 7 | `garden.db` may not exist on main for fresh gardens | `dedup_check.py` exits 0 if garden.db not found |
| 8 | Auto-merge label-based privilege escalation | Labels applied only by CI workflow via GITHUB_TOKEN |
| 9 | `verify_installation` fails due to service startup time | Retry with backoff: poll ports up to 30s at 5s intervals |

---

## Garden entries applied

| Entry | How applied |
|---|---|
| GE-20260422-2afcb2 | Heredoc discipline: quoted for hooks (runtime expansion), unquoted for plists (install-time expansion) |
| GE-20260422-8d2613 | Sentinel-guarded append for hook installation |
| GE-20260802-9f1ff0 | No service ordering needed — engine fix deployed |
| GE-20260803-e363e6 | Acknowledged — `@Scheduled(delayed="60s")` is engine-side, already deployed |
| GE-20260703-eca34b | Fresh install note: no stale cursor issue on first install (no cursor file exists yet) |

---

## Implementation order

1. **Installer** (`scripts/hortora-setup.sh`) — highest standalone value
2. **Auto-update** (`scripts/hortora-update.sh`) — independent, used by installer step 7
3. **Contributor pipeline** (evolved workflow, dedup_check.py, staging branch) — needed by installer step 10
4. **README update** — reflect new setup process

---

## Out of scope (engine-side prerequisites)

- Publishing ONNX model assets as GitHub Release on Hortora/engine
- Any changes to engine or grove source code
- Qdrant version pinning strategy (installer uses latest stable release)
