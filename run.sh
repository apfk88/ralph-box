#!/bin/bash
# Run ralph with optional repo URL

REPO_URL="${1:-}"

if [[ -z "$REPO_URL" ]]; then
  read -p "Repo URL (or press enter to skip): " REPO_URL
fi

if [[ -n "$REPO_URL" ]]; then
  REPO_URL="$REPO_URL" docker-compose run --rm ralph
else
  docker-compose run --rm ralph
fi
