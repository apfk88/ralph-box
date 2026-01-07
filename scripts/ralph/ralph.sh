#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ========================================
# Argument Parsing
# ========================================
VERBOSE=false
MAX_ITERATIONS=0  # 0 = unlimited

while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose) VERBOSE=true; shift ;;
    *) MAX_ITERATIONS=$1; shift ;;
  esac
done

# ========================================
# Colors and Event Emission
# ========================================
C_TIME='\033[0;36m'
C_EVENT='\033[0;32m'
C_WARN='\033[0;33m'
C_NC='\033[0m'

emit() {
  [[ "$VERBOSE" == "true" ]] && return
  printf "${C_TIME}[%s]${C_NC} ${C_EVENT}%s${C_NC}\n" "$(date '+%H:%M:%S')" "$1" >&2
}

emit_warn() {
  printf "${C_TIME}[%s]${C_NC} ${C_WARN}%s${C_NC}\n" "$(date '+%H:%M:%S')" "$1" >&2
}

# ========================================
# File Change Detection
# ========================================
PROGRESS_FILE="$SCRIPT_DIR/progress.md"
TASKS_FILE="$SCRIPT_DIR/tasks.md"

progress_sum=""
tasks_sum=""

get_checksum() {
  if command -v md5sum &>/dev/null; then
    md5sum "$1" 2>/dev/null | cut -d' ' -f1
  else
    md5 -q "$1" 2>/dev/null
  fi
}

init_checksums() {
  progress_sum=$(get_checksum "$PROGRESS_FILE" || echo "")
  tasks_sum=$(get_checksum "$TASKS_FILE" || echo "")
}

check_file_changes() {
  local new_progress=$(get_checksum "$PROGRESS_FILE" || echo "")
  local new_tasks=$(get_checksum "$TASKS_FILE" || echo "")

  if [[ -n "$progress_sum" && "$new_progress" != "$progress_sum" ]]; then
    emit "Progress updated"
  fi
  progress_sum="$new_progress"

  if [[ -n "$tasks_sum" && "$new_tasks" != "$tasks_sum" ]]; then
    emit "Tasks updated"
  fi
  tasks_sum="$new_tasks"
}

# ========================================
# Output Parsing
# ========================================
parse_output() {
  local last_agent_time=0
  while IFS= read -r line; do
    echo "$line"

    # Detect sub-agent launches (throttle to avoid spam)
    if [[ "$VERBOSE" != "true" ]]; then
      if echo "$line" | grep -qiE '(Task tool|Launching.*agent|subagent)'; then
        local now=$(date +%s)
        if (( now - last_agent_time >= 3 )); then
          emit "Sub-agent launched"
          last_agent_time=$now
        fi
      fi
    fi
  done
}

# ========================================
# Main
# ========================================
echo "Starting Ralph"
if [[ $MAX_ITERATIONS -eq 0 ]]; then
  echo "Mode: unlimited iterations"
else
  echo "Mode: max $MAX_ITERATIONS iterations"
fi
[[ "$VERBOSE" == "true" ]] && echo "Verbose: on"

init_checksums

ITERATION=0
while true; do
  ((++ITERATION))

  # Check max iterations (0 = unlimited)
  if [[ $MAX_ITERATIONS -gt 0 && $ITERATION -gt $MAX_ITERATIONS ]]; then
    emit_warn "Max iterations ($MAX_ITERATIONS) reached"
    exit 1
  fi

  # Iteration header
  if [[ $MAX_ITERATIONS -eq 0 ]]; then
    printf "\n═══ Iteration %d ═══\n" "$ITERATION"
  else
    printf "\n═══ Iteration %d/%d ═══\n" "$ITERATION" "$MAX_ITERATIONS"
  fi

  # Run Claude
  if [[ "$VERBOSE" == "true" ]]; then
    # Verbose: raw output
    OUTPUT=$(cat "$SCRIPT_DIR/prompt.md" \
      | claude -p --dangerously-skip-permissions 2>&1 \
      | tee /dev/stderr) || true
  else
    # Normal: parse for events
    OUTPUT=$(cat "$SCRIPT_DIR/prompt.md" \
      | claude -p --dangerously-skip-permissions 2>&1 \
      | tee >(parse_output >&2)) || true
  fi

  # Check file changes
  check_file_changes

  # Check for completion
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    emit "Complete!"
    echo "Done!"
    exit 0
  fi

  sleep 2
done
