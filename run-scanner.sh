#!/usr/bin/env bash
# Wrapper so the garden agent can call dedupe_scanner.py without shell expansions.
# The agent calls: bash run-scanner.sh [args...]
SOREDIUM="${SOREDIUM_PATH:-$HOME/claude/hortora/soredium}"
exec python3 "$SOREDIUM/scripts/dedupe_scanner.py" "$@"
