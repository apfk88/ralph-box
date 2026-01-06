FROM node:20-bookworm

# Base tools for interactive tmux sessions
RUN apt-get update && apt-get install -y \
    git tmux curl ca-certificates less jq ripgrep fzf \
    build-essential python3 python3-pip \
  && rm -rf /var/lib/apt/lists/*

# Install agent CLIs globally
RUN npm install -g @openai/codex @anthropic-ai/claude-code

# Add git-guard wrapper to restrict pushes to allowed repos only
COPY --chmod=755 scripts/git-guard.sh /usr/local/bin/git-guard

# Non-root user
RUN useradd -m -u 1000 dev
USER dev

# Set up aliases for convenience (auto-approve flags for container use)
# git is aliased to git-guard to enforce ALLOWED_REPOS
RUN echo 'alias claude="claude --dangerously-skip-permissions"' >> ~/.bashrc \
 && echo 'alias codex="codex --yolo"' >> ~/.bashrc \
 && echo 'alias git="git-guard"' >> ~/.bashrc

WORKDIR /work
CMD ["bash"]
