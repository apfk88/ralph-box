FROM node:20-bookworm

RUN apt-get update && apt-get install -y \
    git tmux curl ca-certificates less jq ripgrep \
    build-essential python3 python3-pip \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g @openai/codex @anthropic-ai/claude-code

# Add the Ralph harness
COPY --chmod=755 scripts/ralph-loop.sh /usr/local/bin/ralph-loop

RUN useradd -m -u 1000 dev
USER dev

# Set up aliases for convenience (auto-approve flags for container use)
RUN echo 'alias claude="claude --dangerously-skip-permissions"' >> ~/.bashrc \
 && echo 'alias codex="codex --yolo"' >> ~/.bashrc

WORKDIR /work
CMD ["bash"]
