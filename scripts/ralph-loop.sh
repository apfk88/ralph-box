#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ralph-loop --agent claude|codex --prompt PROMPT.md [options]

Options:
  --max-iter N           Default 20
  --complete MARKER      Default "<promise>COMPLETE</promise>"
  --check "CMD"          Optional. Example: --check "npm test"
  --commit-prefix TEXT   Default "ralph"
  --branch NAME          Optional. If set, creates/switches to branch before looping
EOF
}

AGENT=""
PROMPT_FILE=""
MAX_ITER=20
COMPLETE_MARKER="<promise>COMPLETE</promise>"
CHECK_CMD=""
COMMIT_PREFIX="ralph"
BRANCH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2;;
    --prompt) PROMPT_FILE="$2"; shift 2;;
    --max-iter) MAX_ITER="$2"; shift 2;;
    --complete) COMPLETE_MARKER="$2"; shift 2;;
    --check) CHECK_CMD="$2"; shift 2;;
    --commit-prefix) COMMIT_PREFIX="$2"; shift 2;;
    --branch) BRANCH="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

if [[ -z "${AGENT}" || -z "${PROMPT_FILE}" ]]; then
  usage
  exit 1
fi

if [[ ! -f "${PROMPT_FILE}" ]]; then
  echo "Prompt file not found: ${PROMPT_FILE}" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Run inside a git repo (Ralph loop uses git diffs and commits)." >&2
  exit 1
fi

if [[ -n "${BRANCH}" ]]; then
  git switch -c "${BRANCH}" 2>/dev/null || git switch "${BRANCH}"
fi

BASE_PROMPT="$(cat "${PROMPT_FILE}")"

run_agent_once() {
  local iter="$1"
  local marker="$2"

  # We append a deterministic stop condition request each time.
  local prompt="${BASE_PROMPT}

Stop condition:
- When the task is fully complete AND any requested checks pass, print exactly:
${marker}

Important:
- If you changed files, do not forget to save them.
- Prefer small, verifiable steps. Use git status/diff to understand current state."

  if [[ "${AGENT}" == "claude" ]]; then
    # Headless Claude Code: -p/--print prints without interactive UI
    # Using --dangerously-skip-permissions since we're running in a container
    claude --dangerously-skip-permissions -p "${prompt}"
  elif [[ "${AGENT}" == "codex" ]]; then
    # Codex non-interactive single run with --yolo for auto-approve
    codex --yolo exec "${prompt}"
  else
    echo "Unknown agent: ${AGENT} (use claude|codex)" >&2
    exit 1
  fi
}

for i in $(seq 1 "${MAX_ITER}"); do
  echo "== Ralph iteration ${i}/${MAX_ITER} =="

  OUT="$(run_agent_once "${i}" "${COMPLETE_MARKER}" | tee /dev/stderr)"

  if [[ -n "${CHECK_CMD}" ]]; then
    echo "== Running check: ${CHECK_CMD} =="
    # Do not exit loop immediately on check failure; keep iterating.
    if ! bash -lc "${CHECK_CMD}"; then
      echo "Check failed (will continue looping)."
    fi
  fi

  if ! git diff --quiet; then
    git add -A
    git commit -m "${COMMIT_PREFIX}: iter ${i}" >/dev/null || true
  fi

  if echo "${OUT}" | grep -Fq "${COMPLETE_MARKER}"; then
    echo "== Complete marker found. Stopping. =="
    exit 0
  fi
done

echo "== Reached max iterations without completion marker. =="
exit 2
