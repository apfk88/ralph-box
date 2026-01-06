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

## GitHub access

Agents get **read-only** GitHub access via a fine-grained PAT. Create one at:

**https://github.com/settings/tokens?type=beta**

Configure it with:
- **Repository access** → "Only select repositories" or "All repositories"
- **Permissions** → "Contents" → "Read-only"

Add to `.env`:
```bash
GITHUB_TOKEN=github_pat_xxx
```

Agents can clone and fetch but **cannot push**. All commits stay local in `/work/`.

## Workflow

1. Agent clones repos into `/work/` and makes commits locally
2. When done, review their work from your host:
   ```bash
   cd ./repo-name
   git log
   ```
3. Push with your own credentials when you approve:
   ```bash
   git push
   ```

The `/work/` directory is mounted from your host, so all agent work persists after the container exits.

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
docker compose run --rm ralph
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
4. If there are file changes, commit them locally
5. If the agent outputs the completion marker, stop
6. Otherwise, loop back to step 2

This creates backpressure through git diffs, builds, and tests, allowing the agent to iterate toward a solution.

## AI authentication

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
# .env file
OPENAI_API_KEY=your-openai-key
ANTHROPIC_API_KEY=your-anthropic-key
```

## Notes

- Claude Code runs with `--dangerously-skip-permissions` since the container environment is isolated
- Codex runs with `--yolo` for the same reason
- Codex config lives at `~/.codex/config.toml`
- Claude config lives at `~/.claude/`
