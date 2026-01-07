#!/bin/bash
# Run ralph with optional repo URL or local repo name
# Usage: ./run.sh [--loop|--swarm] [--claude|--codex] [repo-url|repo-name]

MODE="swarm"
AI_TOOL="claude"
REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --loop) MODE="loop"; shift ;;
    --swarm) MODE="swarm"; shift ;;
    --claude) AI_TOOL="claude"; shift ;;
    --codex) AI_TOOL="codex"; shift ;;
    *) REPO="$1"; shift ;;
  esac
done

if [[ -z "$REPO" ]]; then
  # List existing repos
  if [[ -d ~/repos ]] && [[ -n "$(ls -A ~/repos 2>/dev/null)" ]]; then
    echo "Existing repos in ~/repos:"
    ls -1 ~/repos
    echo ""
  fi
  read -p "Repo URL or name (enter to skip): " REPO
fi

# Export user ID/group for container
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

SERVICE="ralph-${MODE}"

# Determine if REPO is a URL or local name
if [[ "$REPO" =~ ^https?:// ]] || [[ "$REPO" =~ ^git@ ]]; then
  echo "Starting ${SERVICE} with ${AI_TOOL} (cloning ${REPO})..."
  docker-compose run --rm -e REPO_URL="$REPO" -e AI_TOOL="$AI_TOOL" "$SERVICE"
elif [[ -n "$REPO" ]]; then
  echo "Starting ${SERVICE} with ${AI_TOOL} (using existing repo: ${REPO})..."
  docker-compose run --rm -e REPO_NAME="$REPO" -e AI_TOOL="$AI_TOOL" "$SERVICE"
else
  echo "Starting ${SERVICE} with ${AI_TOOL}..."
  docker-compose run --rm -e AI_TOOL="$AI_TOOL" "$SERVICE"
fi
