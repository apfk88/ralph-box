#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ========================================
# Configuration
# ========================================
AI_TOOL="${AI_TOOL:-claude}"
VERBOSE=false

# AI tool commands
declare -A AI_CMD
AI_CMD[claude]="claude -p --dangerously-skip-permissions"
AI_CMD[codex]="codex --full-auto"

# ========================================
# Argument Parsing
# ========================================
while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose) VERBOSE=true; shift ;;
    --claude) AI_TOOL="claude"; shift ;;
    --codex) AI_TOOL="codex"; shift ;;
    *) shift ;;
  esac
done

# ========================================
# Main
# ========================================
echo "Starting Ralph (swarm mode)"
echo "AI: ${AI_TOOL}"
[[ "$VERBOSE" == "true" ]] && echo "Verbose: on"

CMD="${AI_CMD[$AI_TOOL]}"
if [[ -z "$CMD" ]]; then
  echo "Unknown AI tool: ${AI_TOOL}"
  exit 1
fi

# Run AI once - agent handles everything with subagents
if [[ "$VERBOSE" == "true" ]]; then
  cat "$SCRIPT_DIR/prompt.md" | $CMD 2>&1 | tee /dev/stderr
else
  cat "$SCRIPT_DIR/prompt.md" | $CMD
fi

echo "Done!"
