FROM node:20-bookworm

RUN apt-get update && apt-get install -y \
    git tmux curl ca-certificates less jq ripgrep \
    build-essential python3 python3-pip \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g @openai/codex @anthropic-ai/claude-code

# Entrypoint for setup
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create home directory for arbitrary user (will be mounted as volume)
RUN mkdir -p /home/ralph && chmod 777 /home/ralph

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
