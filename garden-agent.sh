#!/usr/bin/env bash
# garden-agent.sh — invoke Claude harvest+dedup agent (hook or manual mode).
GARDEN_ROOT="${HORTORA_GARDEN:-$HOME/.hortora/garden}"
LOG="$GARDEN_ROOT/garden-agent.log"
LOCK="$GARDEN_ROOT/garden-agent.lock"
TASK="You are the Hortora garden agent. Merge open forage PRs and run the dedup sweep as described in CLAUDE.md."

# Acquire lockfile — prevent concurrent runs (mkdir is atomic).
if ! mkdir "$LOCK" 2>/dev/null; then
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] garden-agent already running, skipping" >> "$LOG"
    exit 0
fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

if [[ "$1" == "--hook" ]] || [[ ! -t 0 ]]; then
    # Rotate log at 1MB, keep last 5
    if [[ -f "$LOG" ]] && [[ $(wc -c < "$LOG") -gt 1048576 ]]; then
        for i in 4 3 2 1; do
            [[ -f "${LOG}.$i" ]] && mv "${LOG}.$i" "${LOG}.$((i+1))"
        done
        mv "$LOG" "${LOG}.1"
    fi
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] garden-agent starting" >> "$LOG"
    claude --print "$TASK" >> "$LOG" 2>&1
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] garden-agent done" >> "$LOG"
else
    claude "$TASK"
fi
