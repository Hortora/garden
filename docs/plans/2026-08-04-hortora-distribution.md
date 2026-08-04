# Hortora Distribution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use executing-plans to
> implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax
> for tracking.

**Goal:** Set up the complete Hortora distribution infrastructure — one-command
installer, contributor pipeline with CI validation, and auto-update service.

**Architecture:** Resumable idempotent bash installer using check/do pairs.
Each step verifies actual system state before acting — no state file, can't
drift from reality. Re-runs skip completed steps and resume partial work
(e.g. interrupted downloads via `curl -C -`). Pre-flight scan shows what's
done and what's left before any work begins.

**Tech Stack:** Bash, GitHub Actions (YAML), Python 3 (dedup script), jq,
launchd (macOS) / systemd (Linux)

## Global Constraints

- Prerequisites: git, Java 25+, jq (hard); python3, gh CLI (soft)
- All paths under `~/.hortora/`
- Installer must be resumable — re-run picks up where it left off
- Each step checks actual system state, not a marker file
- Download resume via `curl -C -` for large files (models ~2.7GB)
- Quoted heredocs for hooks/runtime scripts; unquoted for plists/configs
- Sentinel-guarded append for hook installation
- No service ordering — engine handles Qdrant startup races
- Model download is a prerequisite gate — engine service not started without models
- Pre-flight scan before any work — user sees what will happen
- Confirmation prompt before proceeding (skippable with `--yes`)
- Actionable error messages — say what to DO, not just what went wrong
- End summary — what's running, what to do next

## File Map

| File | Action | Responsibility |
|---|---|---|
| `scripts/hortora-setup.sh` | Create | Main installer (~650 lines) |
| `scripts/hortora-update.sh` | Create | Daily auto-update script (~120 lines) |
| `scripts/dedup_check.py` | Create | CI dedup checker (~100 lines) |
| `.github/workflows/validate-on-pr.yml` | Modify | Evolve for staging + dedup |
| `README.md` | Modify | Update setup instructions |

## Installer Internal Architecture

Every installer step follows this pattern:

```bash
check_<step>() {
    # Returns 0 if step is complete (actual system state verified)
    # Returns 1 if step needs work
    # Prints status for pre-flight scan
}

do_<step>() {
    # Performs the step
    # Handles partial state (resume downloads, retry builds)
    # Prints progress with step number
}
```

The main loop:

```bash
# Phase 1: Pre-flight scan (all checks, no work)
# Phase 2: Show summary + confirmation
# Phase 3: Execute only incomplete steps
# Phase 4: End summary
```

---

### Task 1: Auto-update script

**Files:**
- Create: `scripts/hortora-update.sh`

**Interfaces:**
- Consumes: nothing (standalone)
- Produces: `scripts/hortora-update.sh` — invoked by `io.hortora.update`
  launchd/systemd timer (created by installer in Task 3)

- [ ] **Step 1: Create the update script**

```bash
#!/usr/bin/env bash
set -euo pipefail

HORTORA_HOME="${HORTORA_HOME:-$HOME/.hortora}"
LOG="${HORTORA_HOME}/logs/hortora-update.log"
LOCK="${HORTORA_HOME}/hortora-update.lock"

rotate_log() {
    if [ -f "$LOG" ] && [ "$(wc -c < "$LOG")" -gt 1048576 ]; then
        for i in 4 3 2 1; do
            [ -f "${LOG}.$i" ] && mv "${LOG}.$i" "${LOG}.$((i+1))"
        done
        mv "$LOG" "${LOG}.1"
    fi
}

log() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $1" >> "$LOG"; }

acquire_lock() {
    if ! mkdir "$LOCK" 2>/dev/null; then
        log "SKIP: another update already running"
        exit 0
    fi
    trap 'rmdir "$LOCK" 2>/dev/null' EXIT
}

pull_repo() {
    local path="$1" name="$2" method="${3:-pull}"
    local before after

    if [ ! -d "$path/.git" ] && [ ! -L "$path" ]; then
        log "WARN: $name — not found at $path"
        return 1
    fi

    local real_path="$path"
    [ -L "$path" ] && real_path="$(readlink "$path")"

    before=$(git -C "$real_path" rev-parse HEAD 2>/dev/null) || {
        log "WARN: $name — not a git repo"
        return 1
    }

    if [ "$method" = "fetch-main" ]; then
        git -C "$real_path" fetch origin main:main 2>/dev/null || {
            log "WARN: $name — fetch origin main:main failed (diverged?)"
            return 1
        }
        after=$(git -C "$real_path" rev-parse main 2>/dev/null) || return 1
    else
        git -C "$real_path" pull --ff-only 2>/dev/null || {
            log "WARN: $name — pull --ff-only failed (diverged?)"
            return 1
        }
        after=$(git -C "$real_path" rev-parse HEAD 2>/dev/null) || return 1
    fi

    if [ "$before" != "$after" ]; then
        log "UPDATED: $name (${before:0:8} → ${after:0:8})"
        return 0
    fi
    return 1
}

rebuild_app() {
    local path="$1" name="$2" service="$3"

    local real_path="$path"
    [ -L "$path" ] && real_path="$(readlink "$path")"

    log "BUILDING: $name"
    if (cd "$real_path" && ./mvnw package -DskipTests -q 2>&1); then
        log "BUILD OK: $name"
        if [ "$(uname)" = "Darwin" ]; then
            launchctl kickstart -k "gui/$(id -u)/$service" 2>/dev/null && \
                log "RESTARTED: $service"
        else
            systemctl --user restart "$service" 2>/dev/null && \
                log "RESTARTED: $service"
        fi
    else
        log "BUILD FAILED: $name — keeping current version running"
    fi
}

main() {
    mkdir -p "$(dirname "$LOG")"
    rotate_log
    acquire_lock
    log "--- update started ---"

    pull_repo "$HORTORA_HOME/garden" "garden" "fetch-main" || true

    if pull_repo "$HORTORA_HOME/engine" "engine"; then
        rebuild_app "$HORTORA_HOME/engine" "engine" "io.hortora.engine"
    fi

    if pull_repo "$HORTORA_HOME/grove" "grove"; then
        rebuild_app "$HORTORA_HOME/grove" "grove" "io.hortora.grove"
    fi

    if pull_repo "$HORTORA_HOME/soredium" "soredium"; then
        if command -v python3 >/dev/null 2>&1; then
            local real_path="$HORTORA_HOME/soredium"
            [ -L "$real_path" ] && real_path="$(readlink "$real_path")"
            log "SYNCING: skills"
            python3 "$real_path/scripts/claude-skill" sync-local --all -y \
                2>&1 | while IFS= read -r line; do log "  $line"; done
        else
            log "WARN: python3 not found — skipping skill sync"
        fi
    fi

    log "--- update finished ---"
}

main "$@"
```

- [ ] **Step 2: Make executable and verify**

```bash
chmod +x scripts/hortora-update.sh
bash -n scripts/hortora-update.sh
shellcheck scripts/hortora-update.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/hortora-update.sh
git commit -m "feat: add hortora-update.sh — daily auto-update script

Pulls all repos, rebuilds on change, restarts services.
Uses fetch-main for garden (safe on contributor branches).
Follows symlinks for repos linked from ~/claude/hortora/.
Lock file prevents concurrent runs. Log rotation at 1MB."
```

---

### Task 2: Installer — core framework + pre-flight + platform + prereqs

**Files:**
- Create: `scripts/hortora-setup.sh`

**Interfaces:**
- Consumes: nothing
- Produces: The installer framework with pre-flight scan, confirmation
  prompt, and the first two check/do pairs (platform, prerequisites).
  Sets globals: `$OS`, `$ARCH`, `$QDRANT_ASSET`, `$JAVA_HOME`.
  Later tasks add more check/do pairs into this framework.

- [ ] **Step 1: Create the installer with framework + first two steps**

```bash
#!/usr/bin/env bash
set -euo pipefail

# ── Globals ──────────────────────────────────────────────────────────
HORTORA_HOME="$HOME/.hortora"
GARDEN_ROOT="$HORTORA_HOME/garden"
QDRANT_VERSION="1.14.0"
ENGINE_RELEASE="v0.1.0"
AUTO_YES=false
TOTAL_STEPS=9
MODELS_OK=false

# Populated by detect_platform
OS="" ARCH="" QDRANT_ASSET="" QDRANT_URL=""
# Populated by check_prerequisites
JAVA_HOME="${JAVA_HOME:-}"
HAS_PYTHON3=false HAS_GH=false

# ── Output helpers ───────────────────────────────────────────────────
GREEN='\033[0;32m' YELLOW='\033[0;33m' RED='\033[0;31m'
BOLD='\033[1m' NC='\033[0m'

# Disable color if not a terminal
[ -t 1 ] || { GREEN="" YELLOW="" RED="" BOLD="" NC=""; }

ok()   { printf "  ${GREEN}✓${NC} %s\n" "$1"; }
warn() { printf "  ${YELLOW}⚠${NC} %s\n" "$1"; }
fail() { printf "  ${RED}✗${NC} %s\n" "$1"; exit 1; }
step() { printf "\n${BOLD}[%s/%s] %s${NC}\n" "$1" "$TOTAL_STEPS" "$2"; }
scan() {
    if [ "$1" = "ok" ]; then
        printf "  ${GREEN}[✓]${NC} %s\n" "$2"
    else
        printf "  ${YELLOW}[·]${NC} %s\n" "$2"
    fi
}

# ── Step definitions (check/do pairs) ────────────────────────────────
#
# check_* returns 0 if complete, 1 if work needed.
# do_* performs the work, with progress output.
# Both print status lines for the user.

# ── Step 1: Platform ─────────────────────────────────────────────────

check_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    case "$OS" in
        Darwin)
            case "$ARCH" in
                arm64|aarch64) QDRANT_ASSET="qdrant-aarch64-apple-darwin.tar.gz" ;;
                *) fail "Unsupported macOS architecture: $ARCH (need arm64)" ;;
            esac ;;
        Linux)
            case "$ARCH" in
                x86_64)  QDRANT_ASSET="qdrant-x86_64-unknown-linux-musl.tar.gz" ;;
                aarch64) QDRANT_ASSET="qdrant-aarch64-unknown-linux-musl.tar.gz" ;;
                *) fail "Unsupported Linux architecture: $ARCH (need x86_64 or aarch64)" ;;
            esac ;;
        *) fail "Unsupported OS: $OS (need macOS or Linux)" ;;
    esac
    QDRANT_URL="https://github.com/qdrant/qdrant/releases/download/v${QDRANT_VERSION}/${QDRANT_ASSET}"
    scan ok "$OS $ARCH"
    return 0
}

do_platform() {
    step 1 "Detecting platform"
    check_platform
    ok "$OS $ARCH — Qdrant asset: $QDRANT_ASSET"
}

# ── Step 2: Prerequisites ────────────────────────────────────────────

check_prerequisites() {
    local all_ok=true

    command -v git >/dev/null 2>&1 || { scan todo "git: not found"; return 1; }
    command -v java >/dev/null 2>&1 || { scan todo "java: not found"; return 1; }

    local java_ver
    java_ver=$(java -version 2>&1 | head -1 | sed 's/.*"\([0-9]*\).*/\1/')
    [ "$java_ver" -ge 25 ] 2>/dev/null || {
        scan todo "java: version $java_ver (need 25+)"
        return 1
    }

    command -v jq >/dev/null 2>&1 || {
        scan todo "jq: not found (brew install jq)"
        return 1
    }

    if [ -z "$JAVA_HOME" ]; then
        JAVA_HOME=$(java -XshowSettings:properties 2>&1 | grep 'java.home' | awk '{print $3}')
    fi

    HAS_PYTHON3=false
    command -v python3 >/dev/null 2>&1 && HAS_PYTHON3=true

    HAS_GH=false
    command -v gh >/dev/null 2>&1 && HAS_GH=true

    local extras=""
    [ "$HAS_PYTHON3" = false ] && extras="${extras} (no python3 — skill sync will be manual)"
    [ "$HAS_GH" = false ] && extras="${extras} (no gh — PR creation will be manual)"
    scan ok "git, Java $java_ver, jq${extras}"
    return 0
}

do_prerequisites() {
    step 2 "Checking prerequisites"

    command -v git >/dev/null 2>&1 || fail "git is required — install it first"
    ok "git: $(git --version | head -1)"

    command -v java >/dev/null 2>&1 || fail "Java 25+ is required — install from https://jdk.java.net/"
    local java_ver
    java_ver=$(java -version 2>&1 | head -1 | sed 's/.*"\([0-9]*\).*/\1/')
    [ "$java_ver" -ge 25 ] 2>/dev/null || fail "Java 25+ required, found version $java_ver — upgrade from https://jdk.java.net/"
    if [ -z "$JAVA_HOME" ]; then
        JAVA_HOME=$(java -XshowSettings:properties 2>&1 | grep 'java.home' | awk '{print $3}')
    fi
    ok "java: version $java_ver (JAVA_HOME=$JAVA_HOME)"

    command -v jq >/dev/null 2>&1 || fail "jq is required — install with: brew install jq (macOS) or apt install jq (Linux)"
    ok "jq: $(jq --version)"

    HAS_PYTHON3=false
    if command -v python3 >/dev/null 2>&1; then
        HAS_PYTHON3=true
        ok "python3: $(python3 --version 2>&1)"
    else
        warn "python3 not found — skill sync will need to be done manually"
    fi

    HAS_GH=false
    if command -v gh >/dev/null 2>&1; then
        HAS_GH=true
        ok "gh: $(gh --version | head -1)"
    else
        warn "gh CLI not found — PR creation will need to be done manually"
    fi
}

# Stub check/do pairs for steps 3-9 (filled in by subsequent tasks)
check_qdrant()      { scan todo "Qdrant: not checked"; return 1; }
do_qdrant()         { step 3 "Installing Qdrant"; }
check_repos()       { scan todo "Repos: not checked"; return 1; }
do_repos()          { step 4 "Setting up repos"; }
check_models()      { scan todo "Models: not checked"; return 1; }
do_models()         { step 5 "Downloading models"; }
check_builds()      { scan todo "Builds: not checked"; return 1; }
do_builds()         { step 6 "Building applications"; }
check_services()    { scan todo "Services: not checked"; return 1; }
do_services()       { step 7 "Installing services"; }
check_config()      { scan todo "Config: not checked"; return 1; }
do_config()         { step 8 "Configuring Claude Code + skills"; }
check_contributor() { scan todo "Contributor: not checked"; return 1; }
do_contributor()    { step 9 "Setting up contributor pipeline"; }

# ── Main ─────────────────────────────────────────────────────────────

preflight() {
    printf "\n${BOLD}Hortora Setup — checking current state...${NC}\n\n"

    [ -d "$GARDEN_ROOT/.git" ] || fail "Garden repo not found at $GARDEN_ROOT
    Clone it first:  git clone https://github.com/Hortora/garden.git $GARDEN_ROOT"

    mkdir -p "$HORTORA_HOME/logs"

    local todo=0
    check_platform      || todo=$((todo + 1))
    check_prerequisites || todo=$((todo + 1))
    check_qdrant        || todo=$((todo + 1))
    check_repos         || todo=$((todo + 1))
    check_models        || todo=$((todo + 1))
    check_builds        || todo=$((todo + 1))
    check_services      || todo=$((todo + 1))
    check_config        || todo=$((todo + 1))
    check_contributor   || todo=$((todo + 1))

    echo ""
    if [ "$todo" -eq 0 ]; then
        printf "  ${GREEN}Everything is set up. Nothing to do.${NC}\n"
        exit 0
    fi

    printf "  ${BOLD}%d step(s) to complete.${NC}\n" "$todo"

    if [ "$AUTO_YES" = false ]; then
        printf "\n  Continue? [Y/n] "
        read -r answer
        case "$answer" in
            [nN]*) echo "  Aborted."; exit 0 ;;
        esac
    fi
}

run_steps() {
    # Each step re-checks before doing — preflight results may be stale
    # if the user ran another installer instance between scan and confirm.
    check_platform      || do_platform
    check_prerequisites || do_prerequisites
    check_qdrant        || do_qdrant
    check_repos         || do_repos
    check_models        || do_models
    check_builds        || do_builds
    check_services      || do_services
    check_config        || do_config
    check_contributor   || do_contributor
}

summary() {
    printf "\n${BOLD}╔══════════════════════════════════════════╗${NC}\n"
    printf "${BOLD}║         Hortora setup complete!          ║${NC}\n"
    printf "${BOLD}╚══════════════════════════════════════════╝${NC}\n\n"

    printf "  Services:\n"
    check_port "Qdrant"  6333 2 && ok "Qdrant   http://localhost:6333" || warn "Qdrant   not responding"
    if [ "$MODELS_OK" = true ]; then
        check_port "Engine" 8080 2 && ok "Engine   http://localhost:8080" || warn "Engine   not responding (may still be starting)"
    else
        warn "Engine   not started (models not available yet)"
    fi
    check_port "Grove"  8090 2 && ok "Grove    http://localhost:8090" || warn "Grove    not responding (may still be starting)"

    echo ""
    if [ "$MODELS_OK" = true ]; then
        printf "  First-time indexing runs automatically (~60 min for full corpus).\n"
        printf "  Search improves as indexing progresses.\n"
    else
        printf "  ${YELLOW}Next step:${NC} models are not yet published as GitHub Release assets.\n"
        printf "  Once published, re-run this installer to download them and start the engine.\n"
    fi
    echo ""
    printf "  Daily auto-update runs at 3am.\n"
    printf "  To test: ask Claude ${BOLD}\"search the garden for Qdrant gotchas\"${NC}\n"
    echo ""
}

check_port() {
    local name="$1" port="$2" timeout="${3:-2}"
    curl -sf --max-time "$timeout" "http://localhost:$port" >/dev/null 2>&1 ||
    curl -sf --max-time "$timeout" "http://localhost:$port/q/health" >/dev/null 2>&1
}

main() {
    # Parse flags
    for arg in "$@"; do
        case "$arg" in
            --yes|-y) AUTO_YES=true ;;
            --help|-h)
                echo "Usage: hortora-setup.sh [--yes]"
                echo "  --yes, -y   Skip confirmation prompt"
                exit 0 ;;
        esac
    done

    preflight
    run_steps
    summary
}

main "$@"
```

- [ ] **Step 2: Make executable and verify**

```bash
chmod +x scripts/hortora-setup.sh
bash -n scripts/hortora-setup.sh
shellcheck scripts/hortora-setup.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/hortora-setup.sh
git commit -m "feat: hortora-setup.sh framework — pre-flight scan, check/do pairs

Resumable installer with pre-flight scan, confirmation prompt, color
output, and check/do pair architecture. Steps 1-2 (platform, prereqs)
implemented. Steps 3-9 stubbed for subsequent tasks."
```

---

### Task 3: Installer — Qdrant, repos, models, builds

**Files:**
- Modify: `scripts/hortora-setup.sh` (replace stubs for steps 3-6)

**Interfaces:**
- Consumes: `$OS`, `$ARCH`, `$QDRANT_URL`, `$JAVA_HOME` from Task 2
- Produces: Qdrant at `$HORTORA_HOME/qdrant/qdrant`. Repos at
  `$HORTORA_HOME/{engine,grove,soredium}`. Models at
  `$HORTORA_HOME/models/`. Jars built. `$MODELS_OK` flag set.

- [ ] **Step 1: Implement check/do for Qdrant (step 3)**

Replace the `check_qdrant` and `do_qdrant` stubs:

```bash
# ── Step 3: Qdrant ───────────────────────────────────────────────────

check_qdrant() {
    local qdrant_bin="$HORTORA_HOME/qdrant/qdrant"
    if [ -x "$qdrant_bin" ]; then
        local ver
        ver=$("$qdrant_bin" --version 2>/dev/null | head -1 || echo "unknown")
        scan ok "Qdrant: $ver"
        return 0
    fi
    if [ -f "$qdrant_bin" ]; then
        scan todo "Qdrant: binary exists but not executable"
    else
        scan todo "Qdrant: not installed"
    fi
    return 1
}

do_qdrant() {
    step 3 "Installing Qdrant v${QDRANT_VERSION}"
    local qdrant_dir="$HORTORA_HOME/qdrant"
    local qdrant_bin="$qdrant_dir/qdrant"
    local archive="/tmp/qdrant-${QDRANT_VERSION}.tar.gz"

    mkdir -p "$qdrant_dir"

    if [ -f "$qdrant_bin" ] && [ ! -x "$qdrant_bin" ]; then
        chmod +x "$qdrant_bin"
        ok "Fixed permissions on existing binary"
    fi

    if [ ! -f "$qdrant_bin" ]; then
        ok "Downloading from qdrant/qdrant releases (~45MB)..."
        curl -fSL --progress-bar "$QDRANT_URL" -o "$archive" || \
            fail "Download failed. Check your network connection and try again."
        tar -xzf "$archive" -C "$qdrant_dir"
        rm -f "$archive"
        chmod +x "$qdrant_bin"
        ok "Binary installed"
    fi

    mkdir -p "$qdrant_dir/storage"

    if [ ! -f "$qdrant_dir/config.yaml" ]; then
        cat > "$qdrant_dir/config.yaml" << EOF
storage:
  storage_path: $qdrant_dir/storage
service:
  grpc_port: 6334
  http_port: 6333
EOF
        ok "Config written"
    fi

    ok "Qdrant ready at $qdrant_bin"
}
```

- [ ] **Step 2: Implement check/do for repos (step 4)**

Replace the `check_repos` and `do_repos` stubs:

```bash
# ── Step 4: Repos ────────────────────────────────────────────────────

check_repos() {
    local all_ok=true missing=""
    for repo in engine grove soredium; do
        local target="$HORTORA_HOME/$repo"
        if [ -d "$target/.git" ] || { [ -L "$target" ] && [ -d "$(readlink "$target")/.git" ]; }; then
            : # present
        else
            all_ok=false
            missing="${missing} ${repo}"
        fi
    done
    if [ "$all_ok" = true ]; then
        scan ok "Repos: engine ✓  grove ✓  soredium ✓"
        return 0
    fi
    scan todo "Repos: missing:${missing}"
    return 1
}

do_repos() {
    step 4 "Setting up repos"

    local remote_url proto
    remote_url=$(git -C "$GARDEN_ROOT" remote get-url origin 2>/dev/null)
    if echo "$remote_url" | grep -q "^git@"; then
        proto="git@github.com:Hortora"
    else
        proto="https://github.com/Hortora"
    fi
    ok "Git protocol: $(echo "$remote_url" | grep -q '^git@' && echo SSH || echo HTTPS)"

    for repo in engine grove soredium; do
        local target="$HORTORA_HOME/$repo"

        # Already present (real dir or valid symlink)
        if [ -d "$target/.git" ] || { [ -L "$target" ] && [ -d "$(readlink "$target")/.git" ]; }; then
            ok "$repo: already present"
            continue
        fi

        # Broken symlink — remove it
        if [ -L "$target" ] && [ ! -d "$target" ]; then
            rm -f "$target"
            warn "$repo: removed broken symlink"
        fi

        # Check for existing clone at ~/claude/hortora/<repo>
        local existing="$HOME/claude/hortora/$repo"
        if [ -d "$existing/.git" ]; then
            ln -s "$existing" "$target"
            ok "$repo: symlinked from $existing"
            continue
        fi

        # Clone fresh
        ok "$repo: cloning..."
        if echo "$proto" | grep -q "^git@"; then
            git clone "${proto}/${repo}.git" "$target" -q
        else
            git clone "${proto}/${repo}.git" "$target" -q
        fi
        ok "$repo: cloned"
    done
}
```

- [ ] **Step 3: Implement check/do for models (step 5)**

Replace the `check_models` and `do_models` stubs:

```bash
# ── Step 5: Models ───────────────────────────────────────────────────

check_models() {
    local models_dir="$HORTORA_HOME/models"
    local all_ok=true status=""

    for model in bge-m3 reranker splade; do
        if [ -f "$models_dir/$model/model.onnx" ] && [ -f "$models_dir/$model/tokenizer.json" ]; then
            status="${status} ${model}:✓"
        else
            all_ok=false
            if [ -f "$models_dir/$model/model.onnx" ]; then
                local size
                size=$(wc -c < "$models_dir/$model/model.onnx" 2>/dev/null | tr -d ' ')
                status="${status} ${model}:partial(${size}B)"
            else
                status="${status} ${model}:✗"
            fi
        fi
    done

    if [ "$all_ok" = true ]; then
        MODELS_OK=true
        scan ok "Models:${status}"
        return 0
    fi
    scan todo "Models:${status}"
    return 1
}

do_models() {
    step 5 "Downloading ONNX models (~2.7GB total)"
    local models_dir="$HORTORA_HOME/models"
    local release_url="https://github.com/Hortora/engine/releases/download/${ENGINE_RELEASE}"

    mkdir -p "$models_dir"

    # Check if release assets exist
    local checksum_url="$release_url/checksums.sha256"
    if ! curl -fsSL --head "$checksum_url" >/dev/null 2>&1; then
        warn "Model release assets not published yet on Hortora/engine"
        warn "Engine service will NOT be started until models are available"
        warn "Re-run this installer after models are published"
        MODELS_OK=false
        return
    fi

    curl -fSL "$checksum_url" -o "$models_dir/checksums.sha256"

    local model_assets
    model_assets="bge-m3:model.onnx bge-m3:model.onnx.data bge-m3:tokenizer.json"
    model_assets="$model_assets reranker:model.onnx reranker:tokenizer.json"
    model_assets="$model_assets splade:model.onnx splade:tokenizer.json"

    for entry in $model_assets; do
        local model="${entry%%:*}"
        local asset="${entry#*:}"
        local dest="$models_dir/$model/$asset"
        local url="$release_url/${model}-${asset}"

        mkdir -p "$models_dir/$model"

        if [ -f "$dest" ]; then
            ok "$model/$asset: already downloaded"
            continue
        fi

        ok "$model/$asset: downloading..."
        # -C - resumes partial downloads
        if ! curl -fSL -C - --progress-bar "$url" -o "$dest" 2>&1; then
            warn "$model/$asset: download failed — will retry on next run"
            rm -f "$dest"
        fi
    done

    ok "Verifying checksums..."
    if (cd "$models_dir" && shasum -a 256 -c checksums.sha256 >/dev/null 2>&1); then
        MODELS_OK=true
        ok "All models verified"
    else
        warn "Checksum verification failed — some models may be corrupt"
        warn "Delete the bad files and re-run the installer to re-download"
        MODELS_OK=false
    fi
}
```

- [ ] **Step 4: Implement check/do for builds (step 6)**

Replace the `check_builds` and `do_builds` stubs:

```bash
# ── Step 6: Builds ───────────────────────────────────────────────────

check_builds() {
    local all_ok=true status=""
    for app in engine grove; do
        local app_dir="$HORTORA_HOME/$app"
        [ -L "$app_dir" ] && app_dir="$(readlink "$app_dir")"
        local jar="$app_dir/target/quarkus-app/quarkus-run.jar"
        if [ -f "$jar" ]; then
            status="${status} ${app}:✓"
        else
            all_ok=false
            status="${status} ${app}:✗"
        fi
    done
    if [ "$all_ok" = true ]; then
        scan ok "Builds:${status}"
        return 0
    fi
    scan todo "Builds:${status}"
    return 1
}

do_builds() {
    step 6 "Building applications (~3-5 min each)"
    for app in engine grove; do
        local app_dir="$HORTORA_HOME/$app"
        [ -L "$app_dir" ] && app_dir="$(readlink "$app_dir")"
        local jar="$app_dir/target/quarkus-app/quarkus-run.jar"

        if [ -f "$jar" ]; then
            ok "$app: already built"
            continue
        fi

        ok "$app: building (this may take a few minutes)..."
        if (cd "$app_dir" && JAVA_HOME="$JAVA_HOME" ./mvnw package -DskipTests -q 2>&1); then
            ok "$app: build complete"
        else
            warn "$app: build failed — re-run installer to retry"
            warn "  Check logs: cd $app_dir && ./mvnw package -DskipTests"
        fi
    done
}
```

- [ ] **Step 5: Verify syntax and lint**

```bash
bash -n scripts/hortora-setup.sh
shellcheck scripts/hortora-setup.sh
```

- [ ] **Step 6: Commit**

```bash
git add scripts/hortora-setup.sh
git commit -m "feat: installer steps 3-6 — Qdrant, repos, models, builds

Qdrant binary download + config. Repo clone with symlink detection for
existing ~/claude/hortora/ clones. Model download with curl -C - resume
for partial downloads. Build with actionable error messages on failure.
All steps resumable via check/do pairs."
```

---

### Task 4: Installer — services, config, contributor, verify

**Files:**
- Modify: `scripts/hortora-setup.sh` (replace stubs for steps 7-9, remove all stubs)

**Interfaces:**
- Consumes: `$OS`, `$JAVA_HOME`, `$HORTORA_HOME`, `$MODELS_OK`,
  `$HAS_PYTHON3`, `$HAS_GH` from Tasks 2-3
- Produces: Launchd/systemd services running. MCP server configured.
  Skills synced. Post-commit hook installed. Installer complete.

- [ ] **Step 1: Implement check/do for services (step 7)**

Replace the `check_services` and `do_services` stubs:

```bash
# ── Step 7: Services ─────────────────────────────────────────────────

check_services() {
    local status="" all_ok=true

    if [ "$OS" = "Darwin" ]; then
        for svc in io.hortora.qdrant io.hortora.grove io.hortora.update; do
            if [ -f "$HOME/Library/LaunchAgents/${svc}.plist" ]; then
                status="${status} ${svc##*.}:✓"
            else
                all_ok=false
                status="${status} ${svc##*.}:✗"
            fi
        done
        if [ -f "$HOME/Library/LaunchAgents/io.hortora.engine.plist" ]; then
            status="${status} engine:✓"
        elif [ "$MODELS_OK" = false ]; then
            status="${status} engine:gated"
        else
            all_ok=false
            status="${status} engine:✗"
        fi
    else
        for svc in io.hortora.qdrant io.hortora.engine io.hortora.grove; do
            if [ -f "$HOME/.config/systemd/user/${svc}.service" ]; then
                status="${status} ${svc##*.}:✓"
            else
                all_ok=false
                status="${status} ${svc##*.}:✗"
            fi
        done
        if [ -f "$HOME/.config/systemd/user/io.hortora.update.timer" ]; then
            status="${status} update:✓"
        else
            all_ok=false
            status="${status} update:✗"
        fi
    fi

    if [ "$all_ok" = true ]; then
        scan ok "Services:${status}"
        return 0
    fi
    scan todo "Services:${status}"
    return 1
}

do_services() {
    step 7 "Installing services"
    mkdir -p "$HORTORA_HOME/logs"

    if [ "$OS" = "Darwin" ]; then
        do_launchd_services
    else
        do_systemd_services
    fi
}

write_and_load_plist() {
    local label="$1" content="$2" load="${3:-true}"
    local plist="$HOME/Library/LaunchAgents/${label}.plist"

    if [ -f "$plist" ]; then
        ok "$label: already installed"
        # Ensure it's loaded
        if [ "$load" = true ]; then
            launchctl load "$plist" 2>/dev/null || true
        fi
        return
    fi

    echo "$content" > "$plist"

    if [ "$load" = true ]; then
        launchctl load "$plist" 2>/dev/null
        ok "$label: installed and started"
    else
        ok "$label: installed (not started — see above)"
    fi
}

do_launchd_services() {
    local agents_dir="$HOME/Library/LaunchAgents"
    mkdir -p "$agents_dir"

    # Qdrant
    write_and_load_plist "io.hortora.qdrant" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key><string>io.hortora.qdrant</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HORTORA_HOME/qdrant/qdrant</string>
        <string>--config-path</string>
        <string>$HORTORA_HOME/qdrant/config.yaml</string>
    </array>
    <key>KeepAlive</key><true/>
    <key>RunAtLoad</key><true/>
    <key>StandardOutPath</key><string>$HORTORA_HOME/logs/io.hortora.qdrant.log</string>
    <key>StandardErrorPath</key><string>$HORTORA_HOME/logs/io.hortora.qdrant.err</string>
</dict>
</plist>"

    # Engine (model gate)
    local engine_load=true
    if [ "$MODELS_OK" = false ]; then
        engine_load=false
        warn "Engine service installed but NOT started — models not available"
    fi
    write_and_load_plist "io.hortora.engine" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key><string>io.hortora.engine</string>
    <key>ProgramArguments</key>
    <array>
        <string>$JAVA_HOME/bin/java</string>
        <string>-jar</string>
        <string>$HORTORA_HOME/engine/target/quarkus-app/quarkus-run.jar</string>
    </array>
    <key>WorkingDirectory</key><string>$HORTORA_HOME/engine</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>JAVA_HOME</key><string>$JAVA_HOME</string>
        <key>HORTORA_HOME</key><string>$HORTORA_HOME</string>
    </dict>
    <key>KeepAlive</key><true/>
    <key>RunAtLoad</key><true/>
    <key>StandardOutPath</key><string>$HORTORA_HOME/logs/io.hortora.engine.log</string>
    <key>StandardErrorPath</key><string>$HORTORA_HOME/logs/io.hortora.engine.err</string>
</dict>
</plist>" "$engine_load"

    # Grove
    write_and_load_plist "io.hortora.grove" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key><string>io.hortora.grove</string>
    <key>ProgramArguments</key>
    <array>
        <string>$JAVA_HOME/bin/java</string>
        <string>-jar</string>
        <string>$HORTORA_HOME/grove/target/quarkus-app/quarkus-run.jar</string>
    </array>
    <key>WorkingDirectory</key><string>$HORTORA_HOME/grove</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>JAVA_HOME</key><string>$JAVA_HOME</string>
        <key>HORTORA_HOME</key><string>$HORTORA_HOME</string>
    </dict>
    <key>KeepAlive</key><true/>
    <key>RunAtLoad</key><true/>
    <key>StandardOutPath</key><string>$HORTORA_HOME/logs/io.hortora.grove.log</string>
    <key>StandardErrorPath</key><string>$HORTORA_HOME/logs/io.hortora.grove.err</string>
</dict>
</plist>"

    # Update timer
    write_and_load_plist "io.hortora.update" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key><string>io.hortora.update</string>
    <key>ProgramArguments</key>
    <array>
        <string>$GARDEN_ROOT/scripts/hortora-update.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key><integer>3</integer>
    </dict>
    <key>StandardOutPath</key><string>$HORTORA_HOME/logs/io.hortora.update.log</string>
    <key>StandardErrorPath</key><string>$HORTORA_HOME/logs/io.hortora.update.err</string>
</dict>
</plist>"
}

do_systemd_services() {
    local unit_dir="$HOME/.config/systemd/user"
    mkdir -p "$unit_dir"

    for svc_spec in \
        "io.hortora.qdrant:$HORTORA_HOME/qdrant/qdrant --config-path $HORTORA_HOME/qdrant/config.yaml" \
        "io.hortora.engine:$JAVA_HOME/bin/java -jar $HORTORA_HOME/engine/target/quarkus-app/quarkus-run.jar" \
        "io.hortora.grove:$JAVA_HOME/bin/java -jar $HORTORA_HOME/grove/target/quarkus-app/quarkus-run.jar"
    do
        local name="${svc_spec%%:*}" exec_cmd="${svc_spec#*:}"
        local unit="$unit_dir/${name}.service"
        if [ ! -f "$unit" ]; then
            cat > "$unit" << EOF
[Unit]
Description=Hortora ${name}

[Service]
ExecStart=$exec_cmd
Restart=always
RestartSec=5
Environment=JAVA_HOME=$JAVA_HOME
Environment=HORTORA_HOME=$HORTORA_HOME

[Install]
WantedBy=default.target
EOF
            ok "$name: unit created"
        fi
    done

    if [ ! -f "$unit_dir/io.hortora.update.service" ]; then
        cat > "$unit_dir/io.hortora.update.service" << EOF
[Unit]
Description=Hortora Auto-Update

[Service]
Type=oneshot
ExecStart=$GARDEN_ROOT/scripts/hortora-update.sh
Environment=JAVA_HOME=$JAVA_HOME
Environment=HORTORA_HOME=$HORTORA_HOME
EOF
    fi

    if [ ! -f "$unit_dir/io.hortora.update.timer" ]; then
        cat > "$unit_dir/io.hortora.update.timer" << EOF
[Unit]
Description=Hortora Auto-Update Timer

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
    fi

    systemctl --user daemon-reload 2>/dev/null
    systemctl --user enable --now io.hortora.qdrant 2>/dev/null || true
    if [ "$MODELS_OK" = true ]; then
        systemctl --user enable --now io.hortora.engine 2>/dev/null || true
    else
        warn "Engine service not enabled — models not available"
    fi
    systemctl --user enable --now io.hortora.grove 2>/dev/null || true
    systemctl --user enable --now io.hortora.update.timer 2>/dev/null || true
    ok "systemd services configured"
}
```

- [ ] **Step 2: Implement check/do for config + skills (step 8)**

Replace the `check_config` and `do_config` stubs:

```bash
# ── Step 8: Config + skills ──────────────────────────────────────────

check_config() {
    local status="" all_ok=true

    # MCP config
    local settings="$HOME/.claude/settings.json"
    if [ -f "$settings" ] && jq -e '.mcpServers.hortora' "$settings" >/dev/null 2>&1; then
        status="${status} mcp:✓"
    else
        all_ok=false
        status="${status} mcp:✗"
    fi

    # Skills
    if [ -d "$HOME/.claude/skills" ] && [ "$(ls "$HOME/.claude/skills/" 2>/dev/null | wc -l)" -gt 5 ]; then
        status="${status} skills:✓"
    elif [ "$HAS_PYTHON3" = false ]; then
        status="${status} skills:manual"
    else
        all_ok=false
        status="${status} skills:✗"
    fi

    if [ "$all_ok" = true ]; then
        scan ok "Config:${status}"
        return 0
    fi
    scan todo "Config:${status}"
    return 1
}

do_config() {
    step 8 "Configuring Claude Code + skills"

    # MCP server
    local settings="$HOME/.claude/settings.json"
    mkdir -p "$HOME/.claude"
    [ -f "$settings" ] || echo '{}' > "$settings"

    if jq -e '.mcpServers.hortora' "$settings" >/dev/null 2>&1; then
        ok "MCP server already configured"
    else
        local engine_jar="$HORTORA_HOME/engine/target/quarkus-app/quarkus-run.jar"
        local tmp_settings
        tmp_settings=$(mktemp)
        jq --arg jar "$engine_jar" --arg java "$JAVA_HOME/bin/java" \
            '.mcpServers.hortora = {
                "command": $java,
                "args": ["-jar", $jar, "--mcp"],
                "env": {}
            }' "$settings" > "$tmp_settings"
        mv "$tmp_settings" "$settings"
        ok "MCP server 'hortora' added to $settings"
    fi

    # Skills sync
    if [ "$HAS_PYTHON3" = false ]; then
        warn "python3 not found — sync skills manually:"
        warn "  python3 $HORTORA_HOME/soredium/scripts/claude-skill sync-local --all -y"
        return
    fi
    local soredium="$HORTORA_HOME/soredium"
    [ -L "$soredium" ] && soredium="$(readlink "$soredium")"
    local script="$soredium/scripts/claude-skill"
    if [ ! -f "$script" ]; then
        warn "claude-skill not found at $script"
        return
    fi
    ok "Syncing skills..."
    python3 "$script" sync-local --all -y 2>&1 | tail -3
    ok "Skills synced"
}
```

- [ ] **Step 3: Implement check/do for contributor (step 9)**

Replace the `check_contributor` and `do_contributor` stubs:

```bash
# ── Step 9: Contributor pipeline ─────────────────────────────────────

check_contributor() {
    local hook="$GARDEN_ROOT/.git/hooks/post-commit"
    local sentinel="# hortora: contributor auto-push"
    if [ -f "$hook" ] && grep -qF "$sentinel" "$hook"; then
        scan ok "Contributor: post-commit hook installed"
        return 0
    fi
    scan todo "Contributor: post-commit hook not installed"
    return 1
}

do_contributor() {
    step 9 "Setting up contributor pipeline"
    local hook="$GARDEN_ROOT/.git/hooks/post-commit"
    local sentinel="# hortora: contributor auto-push"

    if [ -f "$hook" ] && grep -qF "$sentinel" "$hook"; then
        ok "Post-commit hook already installed"
        return
    fi

    [ -f "$hook" ] || touch "$hook"
    chmod +x "$hook"

    cat >> "$hook" << 'HOOK_EOF'

# hortora: contributor auto-push
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
HOOK_EOF

    ok "Post-commit hook installed (guarded: main/staging skip, GE-files only)"
}
```

- [ ] **Step 4: Remove all stub functions**

Delete these lines from the file:
```
check_qdrant()      { scan todo "Qdrant: not checked"; return 1; }
do_qdrant()         { step 3 "Installing Qdrant"; }
check_repos()       { scan todo "Repos: not checked"; return 1; }
do_repos()          { step 4 "Setting up repos"; }
check_models()      { scan todo "Models: not checked"; return 1; }
do_models()         { step 5 "Downloading models"; }
check_builds()      { scan todo "Builds: not checked"; return 1; }
do_builds()         { step 6 "Building applications"; }
check_services()    { scan todo "Services: not checked"; return 1; }
do_services()       { step 7 "Installing services"; }
check_config()      { scan todo "Config: not checked"; return 1; }
do_config()         { step 8 "Configuring Claude Code + skills"; }
check_contributor() { scan todo "Contributor: not checked"; return 1; }
do_contributor()    { step 9 "Setting up contributor pipeline"; }
```

- [ ] **Step 5: Verify syntax and lint**

```bash
bash -n scripts/hortora-setup.sh
shellcheck scripts/hortora-setup.sh
```

- [ ] **Step 6: Commit**

```bash
git add scripts/hortora-setup.sh
git commit -m "feat: installer steps 7-9 — services, config, contributor hook

Completes hortora-setup.sh: launchd/systemd services with model gate,
MCP config via jq merge, skill sync, contributor post-commit hook with
branch/file guards. All steps resumable."
```

---

### Task 5: Dedup check script + evolved CI workflow + staging branch

**Files:**
- Create: `scripts/dedup_check.py`
- Modify: `.github/workflows/validate-on-pr.yml`

**Interfaces:**
- Consumes: `garden.db` on main branch (SQLite)
- Produces: JSON output with duplicate candidates. Exit 0 clean, 1 duplicates.
  Workflow labels PRs and auto-merges to staging.

- [ ] **Step 1: Create dedup_check.py**

```python
#!/usr/bin/env python3
"""Check new garden entries for duplicates against main branch corpus."""
import json
import os
import sqlite3
import subprocess
import sys
import tempfile

SIMILARITY_THRESHOLD = 0.8


def jaccard(set_a, set_b):
    if not set_a and not set_b:
        return 0.0
    intersection = set_a & set_b
    union = set_a | set_b
    return len(intersection) / len(union)


def tokenize(text):
    return set(text.lower().split())


def load_existing_entries(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.execute("SELECT id, title, tags FROM entries")
    entries = []
    for row in cursor:
        entry_id, title, tags = row
        tag_set = set(tags.split(",")) if tags else set()
        entries.append({"id": entry_id, "title": title, "tags": tag_set,
                        "title_tokens": tokenize(title)})
    conn.close()
    return entries


def parse_entry_frontmatter(filepath):
    title = ""
    tags = set()
    in_frontmatter = False
    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if line == "---":
                if in_frontmatter:
                    break
                in_frontmatter = True
                continue
            if in_frontmatter:
                if line.startswith("title:"):
                    title = line.split(":", 1)[1].strip().strip('"').strip("'")
                elif line.startswith("tags:"):
                    raw = line.split(":", 1)[1].strip()
                    raw = raw.strip("[]")
                    tags = {t.strip().strip('"').strip("'")
                            for t in raw.split(",") if t.strip()}
    return title, tags


def main():
    if len(sys.argv) < 2:
        print("Usage: dedup_check.py <file1.md> [file2.md ...]",
              file=sys.stderr)
        sys.exit(2)

    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as tmp:
        tmp_db = tmp.name

    try:
        result = subprocess.run(
            ["git", "show", "main:garden.db"],
            stdout=open(tmp_db, "wb"), stderr=subprocess.DEVNULL)
        if result.returncode != 0:
            print(json.dumps({"duplicates": [], "skipped": True,
                              "reason": "garden.db not found on main"}))
            sys.exit(0)

        existing = load_existing_entries(tmp_db)
    finally:
        os.unlink(tmp_db)

    duplicates = []
    for filepath in sys.argv[1:]:
        if not os.path.exists(filepath):
            continue
        title, tags = parse_entry_frontmatter(filepath)
        if not title:
            continue
        title_tokens = tokenize(title)
        for entry in existing:
            title_sim = jaccard(title_tokens, entry["title_tokens"])
            tag_sim = (jaccard(tags, entry["tags"])
                       if tags and entry["tags"] else 0.0)
            combined = 0.7 * title_sim + 0.3 * tag_sim
            if combined >= SIMILARITY_THRESHOLD:
                duplicates.append({
                    "new": os.path.basename(filepath),
                    "existing": entry["id"],
                    "similarity": round(combined, 3),
                })

    print(json.dumps({"duplicates": duplicates}, indent=2))
    sys.exit(1 if duplicates else 0)


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Verify syntax**

```bash
chmod +x scripts/dedup_check.py
python3 -m py_compile scripts/dedup_check.py
```

- [ ] **Step 3: Evolve validate-on-pr.yml**

Overwrite `.github/workflows/validate-on-pr.yml` with the evolved version.
Key changes: fixed GE-ID regex, added dedup check, auto-merge to staging,
auto-flush at 25+ entries, conditional behavior for main vs staging PRs.

```yaml
name: Validate Garden Entry

on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - '*/GE-*.md'
      - 'submissions/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write

    steps:
      - name: Checkout garden
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Checkout soredium
        uses: actions/checkout@v4
        with:
          repository: Hortora/soredium
          path: .soredium

      - name: Install dependencies
        run: pip install pyyaml

      - name: Detect changed entry files
        id: entry
        run: |
          FILES=$(git diff --name-only origin/${{ github.base_ref }}...HEAD \
            | grep -E '^[^/]+/GE-[0-9a-f-]+\.md$' || true)
          if [ -z "$FILES" ]; then
            echo "No garden entry files detected"
            echo "files=" >> $GITHUB_OUTPUT
          else
            FILES_ONELINE=$(echo "$FILES" | tr '\n' ' ' | sed 's/ $//')
            echo "files=$FILES_ONELINE" >> $GITHUB_OUTPUT
          fi

      - name: Validate entries
        id: validate
        if: steps.entry.outputs.files != ''
        run: |
          for FILE in ${{ steps.entry.outputs.files }}; do
            python .soredium/scripts/validate_pr.py "$FILE" . \
              > /tmp/result-$(basename "$FILE").json 2>&1 || true
          done
        continue-on-error: true

      - name: Dedup check
        id: dedup
        if: steps.entry.outputs.files != ''
        run: |
          python3 scripts/dedup_check.py ${{ steps.entry.outputs.files }} \
            > /tmp/dedup.json 2>&1 || true
          DUPES=$(python3 -c "
          import json
          d = json.load(open('/tmp/dedup.json'))
          print(len(d.get('duplicates', [])))" 2>/dev/null || echo 0)
          echo "count=$DUPES" >> $GITHUB_OUTPUT

      - name: Post PR comment
        if: steps.entry.outputs.files != ''
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          BODY="## Garden Entry Validation\n\n"
          BODY="${BODY}Files: ${{ steps.entry.outputs.files }}\n\n"
          if [ -f /tmp/dedup.json ]; then
            DUPES=$(python3 -c "
          import json
          d = json.load(open('/tmp/dedup.json'))
          for dup in d.get('duplicates', []):
              print(f'⚠️ Potential duplicate: {dup[\"new\"]} ↔ {dup[\"existing\"]} (similarity: {dup[\"similarity\"]})')
          " 2>/dev/null)
            if [ -n "$DUPES" ]; then
              BODY="${BODY}### Dedup Check\n${DUPES}\n"
            fi
          fi
          printf "$BODY" | gh pr comment ${{ github.event.pull_request.number }} \
            --body-file -

      - name: Apply labels
        if: steps.entry.outputs.files != ''
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          PR=${{ github.event.pull_request.number }}
          DUPES="${{ steps.dedup.outputs.count }}"
          if [ "${DUPES:-0}" -gt 0 ] 2>/dev/null; then
            gh pr edit $PR --add-label "needs-review"
          else
            gh pr edit $PR --add-label "validated"
          fi

      - name: Auto-merge to staging
        if: >
          steps.entry.outputs.files != '' &&
          github.base_ref == 'staging' &&
          (steps.dedup.outputs.count == '0' || steps.dedup.outputs.count == '')
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh pr merge ${{ github.event.pull_request.number }} --squash --auto

      - name: Auto-flush check
        if: github.base_ref == 'staging'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          COUNT=$(git diff --name-only origin/main...origin/staging \
            | grep -cE '^[^/]+/GE-[0-9a-f-]+\.md$' || echo 0)
          if [ "$COUNT" -ge 25 ]; then
            DOMAINS=$(git diff --name-only origin/main...origin/staging \
              | grep -oE '^[^/]+' | sort | uniq -c | sort -rn | head -5)
            gh pr comment ${{ github.event.pull_request.number }} --body \
              "📦 $COUNT entries on staging ready for promotion.
          Top domains:
          $DOMAINS

          All validated."
          fi
```

- [ ] **Step 4: Create staging branch**

```bash
git branch staging main
git push origin staging
```

- [ ] **Step 5: Commit**

```bash
git add scripts/dedup_check.py .github/workflows/validate-on-pr.yml
git commit -m "feat: contributor pipeline — dedup check, evolved workflow, staging

dedup_check.py: Jaccard similarity against main garden.db, exits 0 if
garden.db missing. validate-on-pr.yml: fixed GE-ID regex, dedup step,
auto-merge to staging, auto-flush at 25+. Staging branch created."
```

---

### Task 6: README update

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: nothing
- Produces: updated setup instructions

- [ ] **Step 1: Replace the Local Setup section**

Find the existing "## Local Setup" section (approximately lines 24-36)
and replace it with:

```markdown
## Local Setup

Clone once per machine, then run the installer:

\`\`\`bash
git clone git@github.com:Hortora/garden.git ~/.hortora/garden
~/.hortora/garden/scripts/hortora-setup.sh
\`\`\`

The installer is resumable — if interrupted, re-run it to pick up where
it left off. It shows a pre-flight scan of what's already done and what's
left before starting any work.

**What it sets up:**
- Qdrant (native binary, no Docker)
- Engine + Grove (Quarkus apps, built from source)
- ONNX models (~2.7GB download)
- Launchd (macOS) or systemd (Linux) services
- Claude Code skills and MCP server
- Contributor post-commit hook

**Prerequisites:** git, Java 25+, jq
**Optional:** python3 (for skill sync), gh CLI (for PR creation)

After install, the engine indexes all garden entries (~60 min for full
corpus). Daily auto-updates keep everything current.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README with installer-based setup

Replaces manual setup instructions with one-command installer.
Documents prerequisites, what gets installed, and resumability."
```

---

## Self-Review

**Spec coverage:**
- ✅ Installer with 9 check/do steps and pre-flight scan (Tasks 2-4)
- ✅ Resumable — re-run skips completed steps, resumes downloads (all tasks)
- ✅ Pre-flight summary with confirmation prompt (Task 2)
- ✅ End summary with service status (Task 2)
- ✅ Auto-update with change detection and log rotation (Task 1)
- ✅ Contributor pipeline with staging, evolved workflow, dedup check (Task 5)
- ✅ Service definitions — launchd + systemd with model gate (Task 4)
- ✅ Post-commit hook with branch/file guards (Task 4)
- ✅ Existing clone detection and symlink (Task 3)
- ✅ Download resume with curl -C - (Task 3)
- ✅ Color output with terminal detection (Task 2)
- ✅ --yes flag for non-interactive mode (Task 2)
- ✅ Actionable error messages (all tasks)
- ✅ README update (Task 6)

**Placeholder scan:** No TBD/TODO. All code blocks complete.

**Type consistency:** Globals (`$HORTORA_HOME`, `$MODELS_OK`, `$JAVA_HOME`,
`$OS`, `$HAS_PYTHON3`, `$HAS_GH`) used consistently across all tasks.
