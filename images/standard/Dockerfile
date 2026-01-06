FROM node:20-bookworm

# Base tools for interactive tmux sessions
RUN apt-get update && apt-get install -y \
    git tmux curl ca-certificates less jq ripgrep fzf \
    build-essential python3 python3-pip \
  && rm -rf /var/lib/apt/lists/*

# Install agent CLIs globally
RUN npm install -g @openai/codex @anthropic-ai/claude-code

# Entrypoint sets up git credentials when GITHUB_TOKEN is provided
COPY --chmod=755 scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# Non-root user
RUN useradd -m -u 1000 dev
USER dev

# Set up aliases for convenience (auto-approve flags for container use)
RUN echo 'alias claude="claude --dangerously-skip-permissions"' >> ~/.bashrc \
 && echo 'alias codex="codex --yolo"' >> ~/.bashrc

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
