FROM node:20-bookworm

RUN apt-get update && apt-get install -y \
    git tmux curl ca-certificates less jq ripgrep \
    build-essential python3 python3-pip \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g @openai/codex @anthropic-ai/claude-code

# Entrypoint for GitHub token setup
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use existing node user (UID 1000) from base image
USER node

# Set up aliases for convenience (auto-approve flags for container use)
RUN echo 'alias claude="claude --dangerously-skip-permissions"' >> ~/.bashrc \
 && echo 'alias codex="codex --yolo"' >> ~/.bashrc

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
