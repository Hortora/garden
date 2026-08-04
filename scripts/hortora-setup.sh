#!/usr/bin/env bash
set -euo pipefail

# ── Globals ──────────────────────────────────────────────────────────
HORTORA_HOME="$HOME/.hortora"
GARDEN_ROOT="$HORTORA_HOME/garden"
QDRANT_VERSION="1.14.0"
ENGINE_RELEASE="v0.1.0"
RELEASE_BASE_URL="${HORTORA_RELEASE_URL:-https://github.com/Hortora/engine/releases/download/${ENGINE_RELEASE}}"
AUTO_YES=false
TOTAL_STEPS=9
MODELS_OK=false

# Populated by detect_platform
OS="" ARCH="" QDRANT_ASSET="" QDRANT_URL=""
# Populated by check_prerequisites
JAVA_HOME="${JAVA_HOME:-}"
HAS_PYTHON3=false HAS_GH=false HAS_NODE=false

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
    check_platform >/dev/null 2>&1
    ok "$OS $ARCH — Qdrant asset: $QDRANT_ASSET"
}

# ── Step 2: Prerequisites ────────────────────────────────────────────

check_prerequisites() {
    command -v git >/dev/null 2>&1 || { scan todo "git: not found"; return 1; }
    command -v java >/dev/null 2>&1 || { scan todo "java: not found"; return 1; }

    local java_ver
    java_ver=$(java -version 2>&1 | grep -oE '"[0-9]+' | grep -oE '[0-9]+')
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

    HAS_NODE=false
    command -v node >/dev/null 2>&1 && HAS_NODE=true

    HAS_YARN=false
    command -v yarn >/dev/null 2>&1 && HAS_YARN=true

    HAS_CLAUDE=false
    command -v claude >/dev/null 2>&1 && HAS_CLAUDE=true

    LOCALE_OK=false
    if locale 2>/dev/null | grep -qiE 'utf-?8'; then
        LOCALE_OK=true
    fi

    local extras=""
    [ "$HAS_PYTHON3" = false ] && extras="${extras}, no python3"
    [ "$HAS_GH" = false ] && extras="${extras}, no gh"
    [ "$HAS_CLAUDE" = false ] && extras="${extras}, no claude"
    [ "$HAS_NODE" = false ] || [ "$HAS_YARN" = false ] && extras="${extras}, no node/yarn"
    [ "$LOCALE_OK" = false ] && extras="${extras}, no UTF-8 locale"
    [ -n "$extras" ] && extras=" (optional missing:${extras#,})"
    scan ok "git, Java $java_ver, jq${extras}"
    return 0
}

do_prerequisites() {
    step 2 "Checking prerequisites"

    command -v git >/dev/null 2>&1 || fail "git is required — install it first"
    ok "git: $(git --version | head -1)"

    command -v java >/dev/null 2>&1 || fail "Java 25+ is required — install from https://jdk.java.net/"
    local java_ver
    java_ver=$(java -version 2>&1 | grep -oE '"[0-9]+' | grep -oE '[0-9]+')
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

    HAS_NODE=false
    HAS_YARN=false
    if command -v node >/dev/null 2>&1; then
        HAS_NODE=true
        ok "node: $(node --version)"
    fi
    if command -v yarn >/dev/null 2>&1; then
        HAS_YARN=true
        ok "yarn: $(yarn --version 2>/dev/null)"
    fi
    if [ "$HAS_NODE" = false ] || [ "$HAS_YARN" = false ]; then
        warn "node/yarn not found — grove and trellis won't build (frontend needs them)"
        warn "  Install: brew install node && npm install -g yarn  (macOS)"
        warn "  Install: dnf install nodejs && npm install -g yarn (Fedora)"
    fi

    HAS_CLAUDE=false
    if command -v claude >/dev/null 2>&1; then
        HAS_CLAUDE=true
        ok "claude: installed"
    else
        warn "Claude Code not found — engine will not start without it"
        warn "  Install: https://docs.anthropic.com/en/docs/claude-code/overview"
        warn "  The engine's search and MCP require the claude CLI at startup."
    fi

    LOCALE_OK=false
    if locale 2>/dev/null | grep -qiE 'utf-?8'; then
        LOCALE_OK=true
        ok "locale: UTF-8"
    else
        warn "UTF-8 locale not detected — engine may fail on non-ASCII filenames"
        warn "  Fix: export LANG=C.UTF-8  (or add to ~/.bashrc)"
        warn "  The installer sets LANG=C.UTF-8 in service configs automatically."
    fi
}

# ── Step 3: Qdrant ───────────────────────────────────────────────────

check_qdrant() {
    local qdrant_bin="$HORTORA_HOME/qdrant/qdrant"
    if [ -x "$qdrant_bin" ]; then
        scan ok "Qdrant: installed"
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

# ── Step 4: Repos ────────────────────────────────────────────────────

check_repos() {
    local all_ok=true missing=""
    for repo in engine grove trellis soredium; do
        local target="$HORTORA_HOME/$repo"
        if [ -d "$target/.git" ] || { [ -L "$target" ] && [ -d "$(readlink "$target")/.git" ]; }; then
            : # present
        else
            all_ok=false
            missing="${missing} ${repo}"
        fi
    done
    if [ "$all_ok" = true ]; then
        scan ok "Repos: engine ✓  grove ✓  trellis ✓  soredium ✓"
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

    for repo in engine grove trellis soredium; do
        local target="$HORTORA_HOME/$repo"

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
        git clone "${proto}/${repo}.git" "$target" -q
        ok "$repo: cloned"
    done
}

# ── Step 5: Models ───────────────────────────────────────────────────

check_models() {
    local models_dir="$HORTORA_HOME/models"
    local all_ok=true status=""

    for model in bge-m3 reranker splade; do
        local has_onnx=false has_tok=false
        [ -f "$models_dir/$model/model.onnx" ] && has_onnx=true
        [ -f "$models_dir/$model/tokenizer.json" ] && has_tok=true

        # BGE-M3 also needs model.onnx.data
        if [ "$model" = "bge-m3" ]; then
            if [ "$has_onnx" = true ] && [ "$has_tok" = true ] && \
               [ -f "$models_dir/$model/model.onnx.data" ]; then
                status="${status} ${model}:✓"
            else
                all_ok=false
                # Check for partial split downloads
                local parts
                parts=$(ls "$models_dir/$model"/model.onnx.data.part-* 2>/dev/null | wc -l | tr -d ' ')
                if [ "$parts" -gt 0 ]; then
                    status="${status} ${model}:partial(${parts}/3 parts)"
                else
                    status="${status} ${model}:✗"
                fi
            fi
        else
            if [ "$has_onnx" = true ] && [ "$has_tok" = true ]; then
                status="${status} ${model}:✓"
            else
                all_ok=false
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

    mkdir -p "$models_dir"

    ok "Source: $RELEASE_BASE_URL"
    local checksum_url="$RELEASE_BASE_URL/checksums.sha256"
    if ! curl -fsSL "$checksum_url" -o /dev/null 2>&1; then
        warn "Model release assets not published yet on Hortora/engine"
        warn "Engine service will NOT be started until models are available"
        warn "Re-run this installer after models are published"
        MODELS_OK=false
        return
    fi

    curl -fSL "$checksum_url" -o "$models_dir/checksums.sha256"

    # Download simple assets (single files)
    local simple_assets
    simple_assets="bge-m3:model.onnx bge-m3:tokenizer.json"
    simple_assets="$simple_assets reranker:model.onnx reranker:tokenizer.json"
    simple_assets="$simple_assets splade:model.onnx splade:tokenizer.json"

    for entry in $simple_assets; do
        local model="${entry%%:*}"
        local asset="${entry#*:}"
        local dest="$models_dir/$model/$asset"
        local url="$RELEASE_BASE_URL/${model}-${asset}"

        mkdir -p "$models_dir/$model"

        if [ -f "$dest" ]; then
            ok "$model/$asset: already downloaded"
            continue
        fi

        ok "$model/$asset: downloading..."
        if ! curl -fSL -C - --progress-bar "$url" -o "$dest" 2>&1; then
            warn "$model/$asset: download failed — will retry on next run"
            rm -f "$dest"
        fi
    done

    # Download BGE-M3 model.onnx.data (split into 3 parts due to GitHub 2GB limit)
    if [ ! -f "$models_dir/bge-m3/model.onnx.data" ]; then
        mkdir -p "$models_dir/bge-m3"
        ok "bge-m3/model.onnx.data: downloading 3 parts (~2.1GB total)..."

        local all_parts_ok=true
        for part in part-aa part-ab part-ac; do
            local dest="$models_dir/bge-m3/model.onnx.data.${part}"
            local url="$RELEASE_BASE_URL/bge-m3-model.onnx.data.${part}"

            if [ -f "$dest" ]; then
                ok "  $part: already downloaded"
                continue
            fi

            ok "  $part: downloading..."
            if ! curl -fSL -C - --progress-bar "$url" -o "$dest" 2>&1; then
                warn "  $part: download failed — will retry on next run"
                rm -f "$dest"
                all_parts_ok=false
            fi
        done

        if [ "$all_parts_ok" = true ]; then
            ok "  Reassembling model.onnx.data..."
            cat "$models_dir/bge-m3"/model.onnx.data.part-* \
                > "$models_dir/bge-m3/model.onnx.data"
            rm -f "$models_dir/bge-m3"/model.onnx.data.part-*
            ok "  Reassembled and cleaned up parts"
        else
            warn "  Some parts missing — reassembly skipped, will retry on next run"
        fi
    else
        ok "bge-m3/model.onnx.data: already downloaded"
    fi

    ok "Verifying checksums..."
    local sha_cmd="sha256sum"
    command -v sha256sum >/dev/null 2>&1 || sha_cmd="shasum -a 256"
    if (cd "$models_dir" && $sha_cmd -c checksums.sha256 >/dev/null 2>&1); then
        MODELS_OK=true
        ok "All models verified"
    else
        warn "Checksum verification failed — some models may be corrupt"
        warn "Delete the bad files and re-run the installer to re-download"
        MODELS_OK=false
    fi
}

# ── Step 6: Builds ───────────────────────────────────────────────────

resolve_path() {
    local path="$1"
    [ -L "$path" ] && path="$(readlink "$path")"
    echo "$path"
}

check_builds() {
    local all_ok=true status=""

    for app in engine grove; do
        local app_dir
        app_dir=$(resolve_path "$HORTORA_HOME/$app")
        local jar="$app_dir/target/quarkus-app/quarkus-run.jar"
        if [ -f "$jar" ]; then
            status="${status} ${app}:✓"
        else
            all_ok=false
            status="${status} ${app}:✗"
        fi
    done

    local trellis_dir
    trellis_dir=$(resolve_path "$HORTORA_HOME/trellis")
    local trellis_jar="$trellis_dir/sidecar/target/quarkus-app/quarkus-run.jar"
    if [ -f "$trellis_jar" ]; then
        status="${status} trellis:✓"
    else
        all_ok=false
        status="${status} trellis:✗"
    fi

    if [ "$all_ok" = true ]; then
        scan ok "Builds:${status}"
        return 0
    fi
    scan todo "Builds:${status}"
    return 1
}

mvn_cmd() {
    if command -v mvn >/dev/null 2>&1; then
        echo "mvn"
    elif [ -x "$1/mvnw" ]; then
        echo "$1/mvnw"
    else
        echo ""
    fi
}

do_builds() {
    step 6 "Building applications (~3-5 min each)"

    for app in engine grove; do
        local app_dir
        app_dir=$(resolve_path "$HORTORA_HOME/$app")
        local jar="$app_dir/target/quarkus-app/quarkus-run.jar"

        if [ -f "$jar" ]; then
            ok "$app: already built"
            continue
        fi

        # Grove has a Quinoa frontend that needs node/yarn
        if [ "$app" = "grove" ] && { [ "$HAS_NODE" = false ] || [ "$HAS_YARN" = false ]; }; then
            warn "$app: skipped — needs node and yarn for frontend build"
            warn "  Install node/yarn, then re-run this installer"
            continue
        fi

        local mvn
        mvn=$(mvn_cmd "$app_dir")
        if [ -z "$mvn" ]; then
            warn "$app: no mvnw or mvn found — install Maven and re-run"
            continue
        fi

        ok "$app: building (this may take a few minutes)..."
        if (cd "$app_dir" && JAVA_HOME="$JAVA_HOME" LANG=C.UTF-8 "$mvn" package -DskipTests -q 2>&1); then
            ok "$app: build complete"
        else
            warn "$app: build failed — re-run installer to retry"
            warn "  Debug: cd $app_dir && $mvn package -DskipTests"
        fi
    done

    local trellis_dir
    trellis_dir=$(resolve_path "$HORTORA_HOME/trellis")
    local trellis_jar="$trellis_dir/sidecar/target/quarkus-app/quarkus-run.jar"

    if [ -f "$trellis_jar" ]; then
        ok "trellis sidecar: already built"
    elif [ "$HAS_NODE" = false ] || [ "$HAS_YARN" = false ]; then
        warn "trellis sidecar: skipped — needs node and yarn for frontend build"
        warn "  Install node/yarn, then re-run this installer"
    else
        local mvn
        mvn=$(mvn_cmd "$trellis_dir")
        if [ -z "$mvn" ]; then
            warn "trellis sidecar: no mvnw or mvn found — install Maven and re-run"
        else
            ok "trellis sidecar: building..."
            if (cd "$trellis_dir" && JAVA_HOME="$JAVA_HOME" LANG=C.UTF-8 "$mvn" -f sidecar/pom.xml package -DskipTests -q 2>&1); then
                ok "trellis sidecar: build complete"
            else
                warn "trellis sidecar: build failed — re-run installer to retry"
                warn "  Debug: cd $trellis_dir && $mvn -f sidecar/pom.xml package -DskipTests"
            fi
        fi
    fi
}

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
        launchctl load "$plist" 2>/dev/null || true
        ok "$label: already installed"
        return
    fi

    printf '%s\n' "$content" > "$plist"

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

    local engine_load=true
    if [ "$MODELS_OK" = false ]; then
        engine_load=false
        warn "Engine service installed but NOT started — models not available"
    fi
    if [ "$HAS_CLAUDE" = false ]; then
        engine_load=false
        warn "Engine service installed but NOT started — claude CLI required (see Hortora/engine#84)"
    fi

    local engine_dir
    engine_dir=$(resolve_path "$HORTORA_HOME/engine")

    write_and_load_plist "io.hortora.engine" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key><string>io.hortora.engine</string>
    <key>ProgramArguments</key>
    <array>
        <string>$JAVA_HOME/bin/java</string>
        <string>-jar</string>
        <string>${engine_dir}/target/quarkus-app/quarkus-run.jar</string>
    </array>
    <key>WorkingDirectory</key><string>${engine_dir}</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>JAVA_HOME</key><string>$JAVA_HOME</string>
        <key>HORTORA_HOME</key><string>$HORTORA_HOME</string>
        <key>LANG</key><string>C.UTF-8</string>
    </dict>
    <key>KeepAlive</key><true/>
    <key>RunAtLoad</key><true/>
    <key>StandardOutPath</key><string>$HORTORA_HOME/logs/io.hortora.engine.log</string>
    <key>StandardErrorPath</key><string>$HORTORA_HOME/logs/io.hortora.engine.err</string>
</dict>
</plist>" "$engine_load"

    local grove_dir
    grove_dir=$(resolve_path "$HORTORA_HOME/grove")

    write_and_load_plist "io.hortora.grove" "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key><string>io.hortora.grove</string>
    <key>ProgramArguments</key>
    <array>
        <string>$JAVA_HOME/bin/java</string>
        <string>-jar</string>
        <string>${grove_dir}/target/quarkus-app/quarkus-run.jar</string>
    </array>
    <key>WorkingDirectory</key><string>${grove_dir}</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>JAVA_HOME</key><string>$JAVA_HOME</string>
        <key>HORTORA_HOME</key><string>$HORTORA_HOME</string>
        <key>LANG</key><string>C.UTF-8</string>
    </dict>
    <key>KeepAlive</key><true/>
    <key>RunAtLoad</key><true/>
    <key>StandardOutPath</key><string>$HORTORA_HOME/logs/io.hortora.grove.log</string>
    <key>StandardErrorPath</key><string>$HORTORA_HOME/logs/io.hortora.grove.err</string>
</dict>
</plist>"

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

    local engine_dir grove_dir
    engine_dir=$(resolve_path "$HORTORA_HOME/engine")
    grove_dir=$(resolve_path "$HORTORA_HOME/grove")

    for svc_name in io.hortora.qdrant io.hortora.engine io.hortora.grove; do
        local unit="$unit_dir/${svc_name}.service"
        [ -f "$unit" ] && continue
        local exec_cmd
        case "$svc_name" in
            *qdrant) exec_cmd="$HORTORA_HOME/qdrant/qdrant --config-path $HORTORA_HOME/qdrant/config.yaml" ;;
            *engine) exec_cmd="$JAVA_HOME/bin/java -jar ${engine_dir}/target/quarkus-app/quarkus-run.jar" ;;
            *grove)  exec_cmd="$JAVA_HOME/bin/java -jar ${grove_dir}/target/quarkus-app/quarkus-run.jar" ;;
        esac
        cat > "$unit" << EOF
[Unit]
Description=Hortora ${svc_name}

[Service]
ExecStart=$exec_cmd
Restart=always
RestartSec=5
Environment=JAVA_HOME=$JAVA_HOME
Environment=HORTORA_HOME=$HORTORA_HOME
Environment=LANG=C.UTF-8

[Install]
WantedBy=default.target
EOF
        ok "$svc_name: unit created"
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
Environment=LANG=C.UTF-8
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
    if [ "$MODELS_OK" = true ] && [ "$HAS_CLAUDE" = true ]; then
        systemctl --user enable --now io.hortora.engine 2>/dev/null || true
    else
        [ "$MODELS_OK" = false ] && warn "Engine service not enabled — models not available"
        [ "$HAS_CLAUDE" = false ] && warn "Engine service not enabled — claude CLI required"
    fi
    systemctl --user enable --now io.hortora.grove 2>/dev/null || true
    systemctl --user enable --now io.hortora.update.timer 2>/dev/null || true
    ok "systemd services configured"
}

# ── Step 8: Config + skills ──────────────────────────────────────────

check_config() {
    local status="" all_ok=true

    local settings="$HOME/.claude/settings.json"
    if [ -f "$settings" ] && jq -e '.mcpServers.hortora' "$settings" >/dev/null 2>&1; then
        status="${status} mcp:✓"
    else
        all_ok=false
        status="${status} mcp:✗"
    fi

    if [ -d "$HOME/.claude/skills" ] && [ "$(ls "$HOME/.claude/skills/" 2>/dev/null | wc -l | tr -d ' ')" -gt 5 ]; then
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

    local settings="$HOME/.claude/settings.json"
    mkdir -p "$HOME/.claude"
    [ -f "$settings" ] || echo '{}' > "$settings"

    if jq -e '.mcpServers.hortora' "$settings" >/dev/null 2>&1; then
        ok "MCP server already configured"
    else
        local engine_dir
        engine_dir=$(resolve_path "$HORTORA_HOME/engine")
        local engine_jar="${engine_dir}/target/quarkus-app/quarkus-run.jar"
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

    if [ "$HAS_PYTHON3" = false ]; then
        warn "python3 not found — sync skills manually:"
        warn "  python3 ~/.hortora/soredium/scripts/claude-skill sync-local --all -y"
        return
    fi
    local soredium
    soredium=$(resolve_path "$HORTORA_HOME/soredium")
    local script="$soredium/scripts/claude-skill"
    if [ ! -f "$script" ]; then
        warn "claude-skill not found at $script"
        return
    fi
    ok "Syncing skills..."
    python3 "$script" sync-local --all -y 2>&1 | tail -3
    ok "Skills synced"
}

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

# ── Main ─────────────────────────────────────────────────────────────

check_port() {
    local port="$1" timeout="${2:-2}"
    curl -sf --max-time "$timeout" "http://localhost:$port" >/dev/null 2>&1 ||
    curl -sf --max-time "$timeout" "http://localhost:$port/q/health" >/dev/null 2>&1
}

preflight() {
    printf "\n${BOLD}Hortora Setup — checking current state...${NC}\n\n"

    [ -d "$GARDEN_ROOT/.git" ] || fail "Garden repo not found at $GARDEN_ROOT
  Clone it first:
    git clone https://github.com/Hortora/garden.git $GARDEN_ROOT"

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
        printf "  ${GREEN}Everything is set up. Nothing to do.${NC}\n\n"
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
    check_platform      >/dev/null 2>&1 || do_platform
    check_prerequisites >/dev/null 2>&1 || do_prerequisites
    check_qdrant        >/dev/null 2>&1 || do_qdrant
    check_repos         >/dev/null 2>&1 || do_repos
    check_models        >/dev/null 2>&1 || do_models
    check_builds        >/dev/null 2>&1 || do_builds
    check_services      >/dev/null 2>&1 || do_services
    check_config        >/dev/null 2>&1 || do_config
    check_contributor   >/dev/null 2>&1 || do_contributor
}

summary() {
    printf "\n${BOLD}╔══════════════════════════════════════════╗${NC}\n"
    printf "${BOLD}║         Hortora setup complete!          ║${NC}\n"
    printf "${BOLD}╚══════════════════════════════════════════╝${NC}\n\n"

    printf "  Services:\n"
    check_port 6333 2 && ok "Qdrant   http://localhost:6333" || warn "Qdrant   not responding yet"
    if [ "$MODELS_OK" = true ] && [ "$HAS_CLAUDE" = true ]; then
        check_port 8080 2 && ok "Engine   http://localhost:8080" || warn "Engine   starting up..."
    else
        [ "$MODELS_OK" = false ] && warn "Engine   not started (models not available)"
        [ "$HAS_CLAUDE" = false ] && warn "Engine   not started (claude CLI required)"
    fi
    check_port 8090 2 && ok "Grove    http://localhost:8090" || warn "Grove    starting up..."

    echo ""
    if [ "$MODELS_OK" = true ] && [ "$HAS_CLAUDE" = true ]; then
        printf "  First-time indexing runs automatically (~60 min for full corpus).\n"
        printf "  Search improves as indexing progresses.\n"
    else
        printf "  ${YELLOW}Next steps to get the engine running:${NC}\n"
        [ "$MODELS_OK" = false ] && printf "  • Models not yet available — re-run installer after they're published\n"
        [ "$HAS_CLAUDE" = false ] && printf "  • Install Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview\n"
        printf "  Then re-run this installer.\n"
    fi
    echo ""
    printf "  Daily auto-update runs at 3am.\n"
    printf "  To test: ask Claude ${BOLD}\"search the garden for Qdrant gotchas\"${NC}\n"
    echo ""
}

main() {
    for arg in "$@"; do
        case "$arg" in
            --yes|-y) AUTO_YES=true ;;
            --help|-h)
                echo "Usage: hortora-setup.sh [--yes]"
                echo ""
                echo "  Installs the complete Hortora stack. Resumable — re-run to"
                echo "  pick up where you left off or retry failed steps."
                echo ""
                echo "  --yes, -y   Skip confirmation prompt"
                echo "  --help, -h  Show this help"
                exit 0 ;;
        esac
    done

    preflight
    run_steps
    summary
}

main "$@"
