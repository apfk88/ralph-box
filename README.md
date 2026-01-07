# ralph-box

Every Ralph needs a home. A containerized environment for running autonomous AI coding agents (i.e. letting Ralphs run wild and free).

## Quick Start

### Option 1: Copy scripts to your repo

```bash
# Clone ralph-box
git clone https://github.com/apfk88/ralph-box.git

# Copy scripts to your project
cp -r ralph-box/scripts/ralph-swarm your-repo/scripts/ralph
chmod +x your-repo/scripts/ralph/ralph.sh

# Run from your repo
cd your-repo
./scripts/ralph/ralph.sh
```

### Option 2: Use Docker container

```bash
# Clone
git clone https://github.com/apfk88/ralph-box.git
cd ralph-box

# Add API keys
cat > .env << 'EOF'
GITHUB_TOKEN=github_pat_xxx
ANTHROPIC_API_KEY=sk-ant-xxx
OPENAI_API_KEY=sk-xxx
EOF

# Build and run
docker-compose build
./run.sh https://github.com/your/repo.git
```

> **macOS:** Use `docker compose` (space, not hyphen) if `docker-compose` fails.

Inside the container:
```bash
ralph           # run until done
ralph -v        # verbose output
```

## Modes

| Mode | Command | Default AI | Description |
|------|---------|------------|-------------|
| swarm | `./run.sh` | claude | Ralph concept by [@GeoffreyHuntley](https://x.com/GeoffreyHuntley) |
| loop | `./run.sh --loop` | codex | Loop mode inspired by [@ryancarson](https://x.com/ryancarson/status/2008548371712135632) |

Override AI tool with `--claude` or `--codex`:
```bash
./run.sh --codex https://github.com/your/repo.git
./run.sh --loop --claude https://github.com/your/repo.git
```

## File Structure

```
scripts/
├── ralph-swarm/
│   ├── ralph.sh
│   ├── prompt.md
│   ├── tasks.md
│   └── progress.md
└── ralph-loop/
    ├── ralph.sh
    ├── prompt.md
    ├── tasks.md
    └── progress.md
```

---

## Detailed Setup

### GCP VM Setup

For long-running agents, use a cloud VM so you can disconnect and let it run.

#### Step 1: Provision VM

```bash
ZONE=us-central1-a

gcloud compute instances create ai-dev-1 \
  --zone=$ZONE \
  --machine-type=e2-standard-2 \
  --image-family=ubuntu-2404-lts-amd64 \
  --image-project=ubuntu-os-cloud \
  --boot-disk-type=pd-ssd \
  --boot-disk-size=100GB
```

#### Step 2: SSH into VM

```bash
gcloud compute ssh ai-dev-1 --zone=us-central1-a
```

> **Optional:** Install [Tailscale](https://tailscale.com/download) for simpler SSH access.

#### Step 3: Install Docker

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
sudo apt-get update && sudo apt-get install -y docker-compose tmux
```

#### Step 4: Clone and configure

```bash
git clone https://github.com/apfk88/ralph-box.git
cd ralph-box

cat > .env << 'EOF'
GITHUB_TOKEN=github_pat_xxx
ANTHROPIC_API_KEY=sk-ant-xxx
OPENAI_API_KEY=sk-xxx
EOF

docker-compose build
```

### Running with tmux

tmux keeps Ralph running when you disconnect:

```bash
tmux new -s ralph
./run.sh https://github.com/your/repo.git
ralph
# Ctrl+B, D to detach
```

Reconnect later:
```bash
tmux attach -t ralph
```

### Multiple Sessions

```bash
tmux new -s repo-a
./run.sh https://github.com/you/repo-a.git
# Ctrl+B, D

tmux new -s repo-b
./run.sh --loop https://github.com/you/repo-b.git
# Ctrl+B, D

tmux ls                    # list sessions
tmux attach -t repo-a      # reattach
```

### GitHub Access

Create a read-only PAT at **https://github.com/settings/tokens?type=beta**

- **Repository access** → Select repositories
- **Permissions** → Contents → Read-only

Agents can clone/fetch but cannot push.

### AI Authentication

**CLI login:**
```bash
docker-compose run --rm ralph-swarm
claude login    # inside container
```

**Or use API keys** in `.env` (see Quick Start).

### Monitoring

```bash
cat scripts/ralph/tasks.md      # task status
cat scripts/ralph/progress.md   # progress log
git log --oneline -10           # commits
```

---

## tmux Reference

Prefix: `Ctrl+B` (press, release, then press key)

| Command | Description |
|---------|-------------|
| `tmux new -s name` | New session |
| `tmux attach -t name` | Attach |
| `tmux ls` | List sessions |
| `Ctrl+B, D` | Detach |
| `Ctrl+B, C` | New window |
| `Ctrl+B, N/P` | Next/prev window |
| `Ctrl+B, %` | Split vertical |
| `Ctrl+B, "` | Split horizontal |
| `Ctrl+B, Arrow` | Move between panes |
| `Ctrl+B, [` | Scroll mode (q to exit) |
