# ralph-box

Ralph-box is a cozy, safe little house for Ralph - the never-stopping yoloing coding AGI - created by [@GeoffreyHuntley](https://x.com/GeoffreyHuntley).

A bash loop that:
1. Pipes a prompt into your AI agent
2. Agent picks high priority tasks from `tasks.md`
3. Agent implements it using subagents
4. Agent runs typecheck + tests
5. Agent commits if passing
6. Agent marks story done
7. Agent logs learnings
8. Loop repeats until done

Memory persists only through:
- Git commits
- `progress.md` (progress)
- `tasks.md` (task status)
- `agents.md` (agent learnings)

## File Structure

```
scripts/ralph/
├── ralph.sh
├── prompt.md
├── tasks.md
└── progress.md
```

## GCP VM Setup

### Step 1: Provision VM

```bash
ZONE=us-central1-a  # or your preferred zone

gcloud compute instances create ai-dev-1 \
  --zone=$ZONE \
  --machine-type=e2-standard-2 \
  --image-family=ubuntu-2404-lts-amd64 \
  --image-project=ubuntu-os-cloud \
  --boot-disk-type=pd-ssd \
  --boot-disk-size=100GB
```

### Step 2: SSH into VM

```bash
gcloud compute ssh ai-dev-1 --zone=us-central1-a
```

> **Optional:** Install [Tailscale](https://tailscale.com/download) on the VM and configure GCP to use Tailscale SSH for simpler, persistent access without gcloud.

### Step 3: Install Docker + Docker Compose

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install docker-compose
sudo apt-get update
sudo apt-get install -y docker-compose

# Verify
docker --version
docker-compose --version
```

### Step 4: Install tmux (required for overnight runs)

```bash
sudo apt-get install -y tmux
```

tmux keeps Ralph running even if your SSH connection drops. See [tmux Reference](#tmux-reference) below.

### Step 5: Clone ralph-box

```bash
git clone https://github.com/apfk88/ralph-box.git
cd ralph-box
```

### Step 6: Create .env file

```bash
cat > .env << 'EOF'
# GitHub read-only PAT (create at https://github.com/settings/tokens?type=beta)
GITHUB_TOKEN=github_pat_xxx

# Anthropic API key (or use `claude login` inside container)
ANTHROPIC_API_KEY=sk-ant-xxx
EOF
```

### Step 7: Build the container

```bash
docker-compose build
```

## Running Ralph

```bash
# Start tmux session
tmux new -s ralph

# Run (prompts for repo URL, or pass as argument)
./run.sh https://github.com/your/repo.git
# or just: ./run.sh (will prompt)

# Inside container (already in repo dir with ralph scripts copied):
# Edit tasks.md with your tasks
# Edit progress.md with codebase context

# Run Ralph
ralph           # unlimited iterations
ralph 10        # max 10 iterations
ralph -v        # verbose (raw CLI output)

# Detach from tmux: Ctrl+B, then D
# Reattach later: tmux attach -t ralph
```

### Review and push (from VM, outside container)

```bash
cd ~/ralph-box/repo-name
git log --oneline
# If approved, push with your own creds
git push
```

## Running Multiple Ralph Sessions

Use separate tmux sessions for each repo:

```bash
tmux new -s repo-a
./run.sh https://github.com/you/repo-a.git
ralph
# Ctrl+B, D to detach

tmux new -s repo-b
./run.sh https://github.com/you/repo-b.git
ralph
# Ctrl+B, D to detach

# List sessions
tmux ls
tmux attach -t repo-a
```

## GitHub Access

Agents get **read-only** GitHub access via a fine-grained PAT. Create one at:

**https://github.com/settings/tokens?type=beta**

Configure it with:
- **Repository access** → "Only select repositories" or "All repositories"
- **Permissions** → "Contents" → "Read-only"

Agents can clone and fetch but **cannot push**. All commits stay local in `/work/`.

## AI Authentication

**Option 1: CLI login (default)**

```bash
docker-compose run --rm ralph

# Inside the container:
claude login          # Opens browser for Anthropic auth
```

**Option 2: API keys**

```bash
# .env file
ANTHROPIC_API_KEY=your-anthropic-key
```

Home directory is persisted via Docker volume, so auth tokens survive container restarts.

## Monitoring

```bash
# Task status
cat scripts/ralph/tasks.md

# Progress log
cat scripts/ralph/progress.md

# Commits
git log --oneline -10
```

## Notes

- Claude Code runs with `--dangerously-skip-permissions` since the container environment is isolated
- Claude config lives at `~/.claude/`

## tmux Reference

All commands use `Ctrl+B` as the prefix (press Ctrl+B, release, then press the key).

### Sessions
| Command | Description |
|---------|-------------|
| `tmux new -s name` | Create new session |
| `tmux attach -t name` | Attach to session |
| `tmux ls` | List sessions |
| `Ctrl+B, D` | Detach from session |
| `Ctrl+B, $` | Rename session |

### Windows (tabs)
| Command | Description |
|---------|-------------|
| `Ctrl+B, C` | Create new window |
| `Ctrl+B, N` | Next window |
| `Ctrl+B, P` | Previous window |
| `Ctrl+B, 0-9` | Switch to window by number |
| `Ctrl+B, ,` | Rename window |
| `Ctrl+B, &` | Kill window |

### Panes (splits)
| Command | Description |
|---------|-------------|
| `Ctrl+B, %` | Split vertical |
| `Ctrl+B, "` | Split horizontal |
| `Ctrl+B, Arrow` | Move between panes |
| `Ctrl+B, X` | Kill pane |
| `Ctrl+B, Z` | Toggle pane zoom (fullscreen) |
| `Ctrl+B, Space` | Cycle pane layouts |

### Scrolling
| Command | Description |
|---------|-------------|
| `Ctrl+B, [` | Enter scroll mode |
| `q` | Exit scroll mode |
| `Up/Down` | Scroll line by line |
| `PgUp/PgDn` | Scroll page by page |

## Credits

- Ralph concept by [@GeoffreyHuntley](https://twitter.com/GeoffreyHuntley)
- Guide by [@ryancarson](https://twitter.com/ryancarson)
