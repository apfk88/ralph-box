FROM node:20-bookworm

# Base tools for interactive tmux sessions
RUN apt-get update && apt-get install -y \
    git tmux curl ca-certificates less jq ripgrep fzf \
    build-essential python3 python3-pip \
  && rm -rf /var/lib/apt/lists/*

# Install agent CLIs globally
# Codex CLI: @openai/codex
# Claude Code: @anthropic-ai/claude-code
RUN npm install -g @openai/codex @anthropic-ai/claude-code

# Non-root user
RUN useradd -m -u 1000 dev
USER dev

# Set up aliases for convenience (auto-approve flags for container use)
RUN echo 'alias claude="claude --dangerously-skip-permissions"' >> ~/.bashrc \
 && echo 'alias codex="codex --yolo"' >> ~/.bashrc

WORKDIR /work
CMD ["bash"]
