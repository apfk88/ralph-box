# ralph-box

Two Docker images for AI-assisted development:

- **standard**: Claude Code + Codex CLI for interactive use (tmux, shells, etc.)
- **ralph**: Same tools, plus a "Ralph Wiggum" outer loop harness that repeatedly runs an agent against a prompt until a completion marker appears

Both CLIs are installed via npm:
- `@openai/codex` - OpenAI Codex CLI
- `@anthropic-ai/claude-code` - Anthropic Claude Code CLI

## Build

```bash
docker compose build
```

## Repo restrictions

Use a GitHub fine-grained PAT to restrict which repos the agent can push to. Create one at:

**https://github.com/settings/tokens?type=beta**

Configure it with:
- **Repository access** → "Only select repositories" → pick allowed repos
- **Permissions** → "Contents" → "Read and write"

Then pass it to the container:

```bash
GITHUB_TOKEN=github_pat_xxx docker compose run --rm standard
```

The token is automatically configured as git credentials on container start. GitHub enforces the repo restrictions server-side - the agent literally cannot push to repos outside the token's scope.

## Standard shell

```bash
docker compose run --rm standard
```

Inside the container you have access to:
- `claude` - Claude Code CLI (aliased with `--dangerously-skip-permissions`)
- `codex` - OpenAI Codex CLI (aliased with `--yolo`)
- `tmux` - Terminal multiplexer
- `git`, `ripgrep`, `fzf`, `jq`, and other dev tools

## Ralph loop container

```bash
GITHUB_TOKEN=github_pat_xxx docker compose run --rm ralph
```

### Example: loop Claude on a prompt until it prints a marker

Create a `PROMPT.md` file in a git repo, then:

```bash
ralph-loop --agent claude --prompt PROMPT.md --max-iter 30 --check "npm test" --complete "<promise>DONE</promise>"
```

### Example: loop Codex

```bash
ralph-loop --agent codex --prompt PROMPT.md --max-iter 30 --check "npm test"
```

### Ralph loop options

```
Usage:
  ralph-loop --agent claude|codex --prompt PROMPT.md [options]

Options:
  --max-iter N           Default 20
  --complete MARKER      Default "<promise>COMPLETE</promise>"
  --check "CMD"          Optional. Example: --check "npm test"
  --commit-prefix TEXT   Default "ralph"
  --branch NAME          Optional. If set, creates/switches to branch before looping
```

## How it works

The Ralph harness implements the "agent in a loop" pattern:

1. Read a prompt from a file
2. Run the agent (claude or codex) with the prompt
3. Run an optional check command (e.g., tests)
4. If there are file changes, commit them
5. If the agent outputs the completion marker, stop
6. Otherwise, loop back to step 2

This creates backpressure through git diffs, builds, and tests, allowing the agent to iterate toward a solution.

## Authentication

### AI services

Home directories are persisted via Docker volumes, so auth tokens survive container restarts.

**Option 1: CLI login (default)**

```bash
docker compose run --rm standard

# Inside the container:
claude login          # Opens browser for Anthropic auth
codex login           # Opens browser for OpenAI/ChatGPT auth
```

**Option 2: API keys**

```bash
# .env file or export in shell
OPENAI_API_KEY=your-openai-key
ANTHROPIC_API_KEY=your-anthropic-key
```

### GitHub

**Option 1: Fine-grained PAT (recommended for agents)**

Restricts which repos the agent can access. See "Repo restrictions" above.

**Option 2: CLI login**

```bash
# Inside the container:
gh auth login
```

Note: CLI login grants access to all your repos - use PAT for restricted sessions.

## Notes

- Claude Code runs with `--dangerously-skip-permissions` since the container environment is isolated
- Codex runs with `--yolo` for the same reason
- Codex config lives at `~/.codex/config.toml`
- Claude config lives at `~/.claude/`
