# ralph-box

Ralph is an autonomous AI coding loop that ships features while you sleep.

Created by [@GeoffreyHuntley](https://x.com/GeoffreyHuntley), it runs Claude Code (or your agent of choice) repeatedly until all tasks are complete.

Each iteration is a fresh context window (keeping threads small). Memory persists via git history and text files.

## How It Works

A bash loop that:
1. Pipes a prompt into your AI agent
2. Agent picks the next story from `prd.json`
3. Agent implements it
4. Agent runs typecheck + tests
5. Agent commits if passing
6. Agent marks story done
7. Agent logs learnings
8. Loop repeats until done

Memory persists only through:
- Git commits
- `progress.txt` (learnings)
- `prd.json` (task status)

## File Structure

```
scripts/ralph/
├── ralph.sh
├── prompt.md
├── prd.json
└── progress.txt
```

## GCP VM Setup

### Step 1: Install Docker + Docker Compose

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

### Step 2: Install tmux (required for overnight runs)

```bash
sudo apt-get install -y tmux
```

tmux keeps Ralph running even if your SSH connection drops.

### Step 3: Clone ralph-box

```bash
git clone https://github.com/apfk88/ralph-box.git
cd ralph-box
```

### Step 4: Create .env file

```bash
cat > .env << 'EOF'
# GitHub read-only PAT (create at https://github.com/settings/tokens?type=beta)
GITHUB_TOKEN=github_pat_xxx

# Anthropic API key (or use `claude login` inside container)
ANTHROPIC_API_KEY=sk-ant-xxx
EOF
```

### Step 5: Build the container

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
# Edit prd.json with your user stories
# Edit progress.txt with codebase context

# Run Ralph
ralph 25

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
ralph 25
# Ctrl+B, D to detach

tmux new -s repo-b
./run.sh https://github.com/you/repo-b.git
ralph 25
# Ctrl+B, D to detach

# List sessions
tmux ls
tmux attach -t repo-a
```

## Configuration

### prd.json

Your task list:

```json
{
  "branchName": "ralph/feature",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add login form",
      "acceptanceCriteria": [
        "Email/password fields",
        "Validates email format",
        "typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

Key fields:
- `branchName` — branch to use
- `priority` — lower = first
- `passes` — set true when done

### progress.txt

Start with context:

```markdown
# Ralph Progress Log
Started: 2024-01-15

## Codebase Patterns
- Migrations: IF NOT EXISTS
- Types: Export from actions.ts

## Key Files
- db/schema.ts
- app/auth/actions.ts
---
```

Ralph appends after each story. Patterns accumulate across iterations.

### prompt.md

Instructions for each iteration. Customize for your project.

## Critical Success Factors

### 1. Small Stories

Must fit in one context window.

```
❌ Too big:
"Build entire auth system"

✅ Right size:
"Add login form"
"Add email validation"
"Add auth server action"
```

### 2. Feedback Loops

Ralph needs fast feedback:
- `npm run typecheck`
- `npm test`

Without these, broken code compounds.

### 3. Explicit Criteria

```
❌ Vague:
"Users can log in"

✅ Explicit:
- Email/password fields
- Validates email format
- Shows error on failure
- typecheck passes
```

### 4. Learnings Compound

By story 10, Ralph knows patterns from stories 1-9.

Two places for learnings:
- `progress.txt` — session memory for Ralph iterations
- `AGENTS.md` — permanent docs for humans and future agents

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
# Story status
cat scripts/ralph/prd.json | jq '.userStories[] | {id, passes}'

# Learnings
cat scripts/ralph/progress.txt

# Commits
git log --oneline -10
```

## Common Gotchas

**Idempotent migrations:**
```sql
ADD COLUMN IF NOT EXISTS email TEXT;
```

**Interactive prompts:**
```bash
echo -e "\n\n\n" | npm run db:generate
```

**Schema changes:**
After editing schema, check:
- Server actions
- UI components
- API routes

**Fixing related files is OK:**
If typecheck requires other changes, make them. Not scope creep.

## Notes

- Claude Code runs with `--dangerously-skip-permissions` since the container environment is isolated
- Claude config lives at `~/.claude/`

## Credits

- Ralph concept by [@GeoffreyHuntley](https://twitter.com/GeoffreyHuntley)
- Guide by [@ryancarson](https://twitter.com/ryancarson)
