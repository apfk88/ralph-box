#!/usr/bin/env bash
# Container entrypoint - sets up git credentials if GITHUB_TOKEN is provided

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  # Configure git to use the token for GitHub HTTPS URLs
  git config --global credential.helper store
  echo "https://x-access-token:${GITHUB_TOKEN}@github.com" > ~/.git-credentials
  chmod 600 ~/.git-credentials
  echo "Git credentials configured from GITHUB_TOKEN"
fi

exec "$@"
