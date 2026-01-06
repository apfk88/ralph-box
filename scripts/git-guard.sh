#!/usr/bin/env bash
# Git wrapper that restricts push/write operations to allowed repos
# Set ALLOWED_REPOS="owner/repo1,owner/repo2" at container start

set -euo pipefail

REAL_GIT="/usr/bin/git"

# Operations that can modify remote repos
WRITE_OPS="push|remote add|remote set-url"

is_write_op() {
  local args="$*"
  echo "$args" | grep -qE "^($WRITE_OPS)"
}

get_remote_repo() {
  # Extract owner/repo from remote URL
  local remote="${1:-origin}"
  local url
  url=$("$REAL_GIT" remote get-url "$remote" 2>/dev/null || echo "")
  # Handle https://github.com/owner/repo.git or git@github.com:owner/repo.git
  echo "$url" | sed -E 's#.*github\.com[:/]([^/]+/[^/]+?)(\.git)?$#\1#'
}

check_allowed() {
  local repo="$1"

  if [[ -z "${ALLOWED_REPOS:-}" ]]; then
    echo "ERROR: ALLOWED_REPOS not set. Set it to a comma-separated list of owner/repo." >&2
    echo "Example: ALLOWED_REPOS=apfk88/ralph-box,apfk88/other-repo" >&2
    return 1
  fi

  IFS=',' read -ra allowed <<< "$ALLOWED_REPOS"
  for r in "${allowed[@]}"; do
    if [[ "$repo" == "$r" ]]; then
      return 0
    fi
  done

  echo "ERROR: Push to '$repo' blocked. Allowed repos: $ALLOWED_REPOS" >&2
  return 1
}

# If it's a write operation, check the repo
if is_write_op "$@"; then
  # For push, get the remote (default: origin)
  if [[ "$1" == "push" ]]; then
    remote="${2:-origin}"
    # Handle case where $2 is a flag
    [[ "$remote" == -* ]] && remote="origin"
    repo=$(get_remote_repo "$remote")
    check_allowed "$repo" || exit 1
  fi
fi

exec "$REAL_GIT" "$@"
