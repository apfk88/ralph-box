#!/bin/bash
# Run ralph with optional repo URL
# Usage: ./run.sh [--loop|--swarm] [--claude|--codex] [repo-url]

MODE="swarm"
AI_TOOL="claude"
REPO_URL=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --loop) MODE="loop"; shift ;;
    --swarm) MODE="swarm"; shift ;;
    --claude) AI_TOOL="claude"; shift ;;
    --codex) AI_TOOL="codex"; shift ;;
    *) REPO_URL="$1"; shift ;;
  esac
done

if [[ -z "$REPO_URL" ]]; then
  read -p "Repo URL (or press enter to skip): " REPO_URL
fi

# Export user ID/group for container (UID is readonly, use different name)
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

SERVICE="ralph-${MODE}"
echo "Starting ${SERVICE} with ${AI_TOOL}..."

if [[ -n "$REPO_URL" ]]; then
  docker-compose run --rm -e REPO_URL="$REPO_URL" -e AI_TOOL="$AI_TOOL" "$SERVICE"
else
  docker-compose run --rm -e AI_TOOL="$AI_TOOL" "$SERVICE"
fi
