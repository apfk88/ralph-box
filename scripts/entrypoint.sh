#!/usr/bin/env bash
# Container entrypoint

# Determine ralph mode (swarm or loop)
RALPH_MODE="${RALPH_MODE:-swarm}"

# Set default git identity
git config --global user.name "ralph"
git config --global user.email "ralph@localhost"

# Set up git credentials if GITHUB_TOKEN is provided
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  git config --global credential.helper store
  echo "https://x-access-token:${GITHUB_TOKEN}@github.com" > ~/.git-credentials
  chmod 600 ~/.git-credentials
  echo "Git credentials configured from GITHUB_TOKEN"
fi

# Auto-clone repo if REPO_URL is set
if [[ -n "${REPO_URL:-}" ]]; then
  REPO_NAME=$(basename "${REPO_URL}" .git)
  REPO_PATH="/repos/${REPO_NAME}"

  if [[ ! -d "${REPO_PATH}" ]]; then
    echo "Cloning ${REPO_URL}..."
    git clone "${REPO_URL}" "${REPO_PATH}"
  else
    echo "Repo already exists at ${REPO_PATH}"
  fi

  # Copy ralph scripts based on mode
  if [[ ! -d "${REPO_PATH}/scripts/ralph" ]]; then
    echo "Copying ralph-${RALPH_MODE} scripts..."
    mkdir -p "${REPO_PATH}/scripts"
    cp -r "/ralph/scripts/ralph-${RALPH_MODE}" "${REPO_PATH}/scripts/ralph"
  fi

  # Add auto-cd to bashrc so shell starts in repo
  echo "cd ${REPO_PATH}" >> ~/.bashrc
  echo "Ready: ${REPO_PATH} (mode: ${RALPH_MODE})"

# Use existing repo if REPO_NAME is set
elif [[ -n "${REPO_NAME:-}" ]]; then
  REPO_PATH="/repos/${REPO_NAME}"

  if [[ ! -d "${REPO_PATH}" ]]; then
    echo "Error: Repo not found at ${REPO_PATH}"
    echo "Available repos:"
    ls -1 /repos 2>/dev/null || echo "  (none)"
  else
    # Copy ralph scripts based on mode if not present
    if [[ ! -d "${REPO_PATH}/scripts/ralph" ]]; then
      echo "Copying ralph-${RALPH_MODE} scripts..."
      mkdir -p "${REPO_PATH}/scripts"
      cp -r "/ralph/scripts/ralph-${RALPH_MODE}" "${REPO_PATH}/scripts/ralph"
    fi

    # Add auto-cd to bashrc so shell starts in repo
    echo "cd ${REPO_PATH}" >> ~/.bashrc
    echo "Ready: ${REPO_PATH} (mode: ${RALPH_MODE})"
  fi
fi

# Set up bashrc with prompt, aliases and ralph function
cat >> ~/.bashrc << 'EOF'

# Custom prompt (since UID not in /etc/passwd)
export PS1='ralph@\h:\w\$ '

# Aliases
alias claude="claude --dangerously-skip-permissions"
alias codex="codex --yolo"

# Ralph shortcut
ralph() {
  if [[ -f "./scripts/ralph/ralph.sh" ]]; then
    ./scripts/ralph/ralph.sh "$@"
  else
    echo "ralph scripts not found in ./scripts/ralph/"
    echo "Run from repo root or copy scripts first"
  fi
}
EOF

exec "$@"
