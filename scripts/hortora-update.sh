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

    if pull_repo "$HORTORA_HOME/trellis" "trellis"; then
        local trellis_path="$HORTORA_HOME/trellis"
        [ -L "$trellis_path" ] && trellis_path="$(readlink "$trellis_path")"
        log "BUILDING: trellis sidecar"
        if (cd "$trellis_path" && ./mvnw -f sidecar/pom.xml package -DskipTests -q 2>&1); then
            log "BUILD OK: trellis sidecar"
        else
            log "BUILD FAILED: trellis sidecar — keeping current version"
        fi
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
