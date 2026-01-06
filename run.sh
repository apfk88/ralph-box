#!/bin/bash
# Run ralph with optional repo URL

REPO_URL="${1:-}"

if [[ -z "$REPO_URL" ]]; then
  read -p "Repo URL (or press enter to skip): " REPO_URL
fi

# Export UID/GID so container runs as current user
export UID=$(id -u)
export GID=$(id -g)

if [[ -n "$REPO_URL" ]]; then
  docker-compose run --rm -e REPO_URL="$REPO_URL" ralph
else
  docker-compose run --rm ralph
fi
