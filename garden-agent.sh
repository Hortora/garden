#!/usr/bin/env bash
# garden-agent.sh — invoke Claude dedup agent (hook or manual mode).
GARDEN_ROOT="${HORTORA_GARDEN:-$HOME/.hortora/garden}"
LOG="$GARDEN_ROOT/garden-agent.log"
TASK="You are the Hortora garden deduplication agent. Run the dedup sweep as described in CLAUDE.md."

if [[ "$1" == "--hook" ]] || [[ ! -t 0 ]]; then
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] garden-agent starting" >> "$LOG"
    claude --print "$TASK" >> "$LOG" 2>&1
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] garden-agent done" >> "$LOG"
else
    claude "$TASK"
fi
