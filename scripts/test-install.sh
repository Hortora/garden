#!/usr/bin/env bash
set -uo pipefail

# Repeatable installer test in a podman container.
# Starts a systemd-enabled Linux container, installs prerequisites,
# clones the garden, runs hortora-setup.sh, and verifies services respond.
#
# Usage:
#   ./scripts/test-install.sh          # full test (downloads models from GitHub ~2.7GB)
#   ./scripts/test-install.sh --local  # serve models from host (tests download+reassembly, fast)
#   ./scripts/test-install.sh --quick  # mount models from host (skips download entirely)
#
# Access from host browser:
#   Qdrant:  http://localhost:16333
#   Engine:  http://localhost:18080
#   Grove:   http://localhost:18090

CONTAINER_NAME="hortora-test"
JDK_VERSION="25.0.2"
JDK_URL="https://download.oracle.com/java/25/archive/jdk-${JDK_VERSION}_linux-aarch64_bin.tar.gz"
QUICK=false
LOCAL_MODELS=false
MODEL_SERVER_PID=""
MODEL_SERVER_PORT=19999
RELEASE_ASSETS="/tmp/hortora-release"

for arg in "$@"; do
    case "$arg" in
        --quick) QUICK=true ;;
        --local) LOCAL_MODELS=true ;;
    esac
done

GREEN='\033[0;32m' YELLOW='\033[0;33m' RED='\033[0;31m'
BOLD='\033[1m' NC='\033[0m'
ok()   { printf "  ${GREEN}✓${NC} %s\n" "$1"; }
warn() { printf "  ${YELLOW}⚠${NC} %s\n" "$1"; }
fail() { printf "  ${RED}✗${NC} %s\n" "$1"; }
step() { printf "\n${BOLD}==> %s${NC}\n" "$1"; }

start_model_server() {
    if [ "$LOCAL_MODELS" = true ]; then
        step "Starting local model server"
        if [ ! -d "$RELEASE_ASSETS" ]; then
            fail "Release assets not found at $RELEASE_ASSETS"
            fail "Run the release upload first, or use --quick instead"
            exit 1
        fi
        python3 -m http.server "$MODEL_SERVER_PORT" \
            --directory "$RELEASE_ASSETS" \
            --bind 0.0.0.0 >/dev/null 2>&1 &
        MODEL_SERVER_PID=$!
        sleep 1
        if kill -0 "$MODEL_SERVER_PID" 2>/dev/null; then
            ok "Serving models on port $MODEL_SERVER_PORT (PID $MODEL_SERVER_PID)"
        else
            fail "Model server failed to start"
            exit 1
        fi
    fi
}

stop_model_server() {
    if [ -n "$MODEL_SERVER_PID" ]; then
        kill "$MODEL_SERVER_PID" 2>/dev/null || true
        wait "$MODEL_SERVER_PID" 2>/dev/null || true
    fi
}

cleanup() {
    step "Cleaning up previous test container"
    podman stop "$CONTAINER_NAME" 2>/dev/null || true
    podman rm "$CONTAINER_NAME" 2>/dev/null || true
    stop_model_server
    ok "Clean"
}

build_image() {
    local image_name="hortora-test-base"
    if podman image exists "$image_name" 2>/dev/null; then
        ok "Base image already built"
        return
    fi
    step "Building systemd-enabled base image (one-time)"
    local tmpdir
    tmpdir=$(mktemp -d)
    cat > "$tmpdir/Containerfile" << 'CEOF'
FROM registry.fedoraproject.org/fedora:42
RUN dnf install -y systemd git jq curl tar gzip findutils diffutils procps-ng && dnf clean all
CMD ["/usr/lib/systemd/systemd"]
CEOF
    podman build -t "$image_name" -f "$tmpdir/Containerfile" "$tmpdir"
    rm -rf "$tmpdir"
    ok "Base image built"
}

start_container() {
    step "Starting systemd container"

    build_image

    local volumes=""
    if [ "$QUICK" = true ]; then
        volumes="-v $HOME/.hortora/models:/mnt/models:ro"
        warn "Quick mode: mounting host models (skips 2.7GB download)"
    fi

    podman run -d --privileged \
        --name "$CONTAINER_NAME" \
        -p 16333:6333 \
        -p 18080:8080 \
        -p 18090:8090 \
        $volumes \
        --tmpfs /tmp \
        --tmpfs /run \
        hortora-test-base

    # Wait for systemd to be ready
    local retries=0
    while true; do
        local state
        state=$(podman exec "$CONTAINER_NAME" systemctl is-system-running 2>/dev/null) || true
        case "$state" in
            running|degraded) break ;;
        esac
        retries=$((retries + 1))
        [ "$retries" -gt 30 ] && { fail "systemd not ready after 30s"; return 1; }
        sleep 1
    done
    ok "Container running with systemd ($state)"
}

install_prerequisites() {
    step "Installing JDK + Maven in container"

    # System packages (git, jq, curl, etc.) are in the base image.
    # JDK + Maven installed separately.
    podman exec "$CONTAINER_NAME" bash -c "
        if [ -d /opt/jdk-${JDK_VERSION} ]; then
            echo 'JDK already installed'
        else
            echo 'Downloading JDK ${JDK_VERSION}...'
            curl -fSL '${JDK_URL}' -o /tmp/jdk.tar.gz
            tar -xzf /tmp/jdk.tar.gz -C /opt/
            rm /tmp/jdk.tar.gz
        fi
        ln -sf /opt/jdk-${JDK_VERSION}/bin/java /usr/local/bin/java
        ln -sf /opt/jdk-${JDK_VERSION}/bin/javac /usr/local/bin/javac
        ln -sf /opt/jdk-${JDK_VERSION}/bin/jar /usr/local/bin/jar
        echo 'export JAVA_HOME=/opt/jdk-${JDK_VERSION}' > /etc/profile.d/java.sh
        echo 'export PATH=/opt/jdk-${JDK_VERSION}/bin:\$PATH' >> /etc/profile.d/java.sh
    "
    ok "JDK ${JDK_VERSION} installed"

    podman exec "$CONTAINER_NAME" java -version 2>&1 | head -1

    # Install Maven (grove and trellis don't have mvnw wrappers)
    podman exec "$CONTAINER_NAME" bash -c '
        if ! command -v mvn >/dev/null 2>&1; then
            dnf install -y -q maven 2>&1 | tail -1
        fi
    '
    ok "Maven installed"
}

clone_garden() {
    step "Cloning garden repo"
    podman exec "$CONTAINER_NAME" bash -c '
        if [ -d ~/.hortora/garden/.git ]; then
            echo "Garden already cloned"
        else
            git clone https://github.com/Hortora/garden.git ~/.hortora/garden -q
        fi
    '
    ok "Garden cloned"
}

setup_quick_models() {
    if [ "$QUICK" = true ]; then
        step "Linking host models (quick mode)"
        podman exec "$CONTAINER_NAME" bash -c '
            mkdir -p ~/.hortora/models
            for model in bge-m3 reranker splade; do
                if [ -d "/mnt/models/$model" ]; then
                    cp -r "/mnt/models/$model" "$HOME/.hortora/models/$model"
                fi
            done
        '
        ok "Models copied from host mount"
    fi
}

run_installer() {
    step "Running hortora-setup.sh"
    local release_env=""
    if [ "$LOCAL_MODELS" = true ]; then
        local host_ip
        host_ip=$(podman inspect "$CONTAINER_NAME" --format '{{.NetworkSettings.Gateway}}')
        release_env="HORTORA_RELEASE_URL=http://${host_ip}:${MODEL_SERVER_PORT}"
        ok "Model download URL: $release_env"
    fi
    podman exec \
        -e "JAVA_HOME=/opt/jdk-${JDK_VERSION}" \
        ${release_env:+-e "$release_env"} \
        "$CONTAINER_NAME" bash -c '
        export JAVA_HOME=/opt/jdk-'"${JDK_VERSION}"'
        export PATH="$JAVA_HOME/bin:$PATH"
        ~/.hortora/garden/scripts/hortora-setup.sh --yes
    '
}

verify() {
    step "Verifying from host"
    local all_ok=true

    for spec in "Qdrant:16333" "Engine:18080" "Grove:18090"; do
        local name="${spec%%:*}" port="${spec#*:}"
        local retries=0
        while [ "$retries" -lt 12 ]; do
            if curl -sf --max-time 2 "http://localhost:$port" >/dev/null 2>&1 || \
               curl -sf --max-time 2 "http://localhost:$port/q/health" >/dev/null 2>&1; then
                ok "$name responding on localhost:$port"
                break
            fi
            retries=$((retries + 1))
            sleep 5
        done
        if [ "$retries" -ge 12 ]; then
            fail "$name not responding on localhost:$port after 60s"
            all_ok=false
        fi
    done

    echo ""
    if [ "$all_ok" = true ]; then
        printf "${GREEN}${BOLD}All services responding!${NC}\n\n"
        printf "  Open in browser:\n"
        printf "    Grove:   ${BOLD}http://localhost:18090${NC}\n"
        printf "    Qdrant:  ${BOLD}http://localhost:16333/dashboard${NC}\n"
        printf "    Engine:  ${BOLD}http://localhost:18080${NC}\n"
    else
        printf "${YELLOW}Some services not responding — check container logs:${NC}\n"
        printf "    podman exec $CONTAINER_NAME journalctl --user -u io.hortora.engine\n"
        printf "    podman exec $CONTAINER_NAME cat ~/.hortora/logs/io.hortora.engine.err\n"
    fi

    echo ""
    printf "Container is running. To stop:\n"
    printf "    podman stop $CONTAINER_NAME && podman rm $CONTAINER_NAME\n"
    printf "To exec in:\n"
    printf "    podman exec -it $CONTAINER_NAME bash\n"
}

main() {
    printf "\n${BOLD}Hortora Installer Test${NC}\n"
    if [ "$QUICK" = true ]; then
        printf "  Mode: quick (host models mounted, skips download)\n"
    elif [ "$LOCAL_MODELS" = true ]; then
        printf "  Mode: local (models served from host, tests download+reassembly)\n"
    else
        printf "  Mode: full (downloads everything from GitHub)\n"
    fi
    printf "  Container: $CONTAINER_NAME\n"
    printf "  Ports: 16333 (Qdrant), 18080 (Engine), 18090 (Grove)\n\n"

    cleanup
    start_model_server
    start_container
    install_prerequisites
    clone_garden
    setup_quick_models
    run_installer
    verify
}

main "$@"
