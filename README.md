# blueprint OSS

blueprint OSS is a lightweight set of reusable, copy‑first assets you can drop into any repository to bootstrap consistent execution playbooks, agent prompts, and engineering standards. It ships with an installer that copies opinionated instructions and standards into a target project, and can optionally scaffold prompts for popular AI coding tools.

## What’s Inside

- Instructions: execution playbooks for common flows (plan product, create spec, execute tasks).
- Standards: engineering practices, code and language style guides, and tech‑stack guidance.
- Commands: task-oriented docs that map to assistant prompts and tool rules.
- Agents: specialized agent guides (e.g., file creator, project manager).
- Setup scripts: a small Bash installer that wires the files into a project.

This repository is meant to be cloned to `~/.blueprint-oss` and used from other projects. When installed into a project, files land under that project’s `.blueprint-oss/` directory.

## Using blueprint

- Pick a workflow:
  - **Plan Product**: start a new product from scratch. Open `instructions/core/plan-product.md`.
  - **Analyze Product**: set up mission/roadmap for an existing product and establish team standards. It creates/updates coding style guides, tech stack, and best practices under `.blueprint-oss/standards/`. Open `instructions/core/analyze-product.md`.
  - **Create Priority Item**: fast‑track a spec for a new feature. Open `instructions/core/create-priority-item.md`.
  - **Create Spec**: write a detailed spec. Open `instructions/core/create-spec.md`.
  - **Create Tasks**: turn the spec into actionable tasks. Open `instructions/core/create-tasks.md`.
  - **Execute Tasks**: build and ship the feature. Open `instructions/core/execute-tasks.md`.
  - **Update Roadmap**: revise plans and priorities. Open `instructions/core/update-roadmap.md`.
- Use with your IDE/agent (optional): if you installed integrations, trigger the same flows via command keywords:
  - Claude Code: `/plan-product`, `/analyze-product`, `/create-priority-item`, `/create-spec`, `/create-tasks`, `/execute-tasks`, `/update-roadmap`.
  - Cursor: `@plan-product`, `@analyze-product`, `@create-priority-item`, `@create-spec`, `@create-tasks`, `@execute-tasks`, `@update-roadmap`.
  - Codex: prompts are available in `~/.codex/prompts` under the same names.
- What gets created in your repo:
  - `.blueprint-oss/instructions/` — core and meta checklists you follow.
  - `.blueprint-oss/standards/` — best practices and style guides.
  - `.claude/` or `.cursor/rules/` — only if you enabled those integrations.
  - No commits are made automatically; you keep control via your normal Git flow.
- Refresh or update:
  - Re-run the installer at any time. To replace existing files, use `--overwrite-instructions` and/or `--overwrite-standards`.
  - To add IDE/agent support later, re-run with `--claude`, `--cursor`, and/or `--codex`.

## Quick Start

Install blueprint OSS (once, to your home directory)

```bash
git clone git@github.com-supagoku:SupaGoku/blueprint-oss.git ~/.blueprint-oss
```

Install into the current project (creates `.blueprint-oss/` in this repo)

```bash
~/.blueprint-oss/setup/project.sh
```

OR if you installed the alias just run blue

```bash
blue
```

## Common options:

- `--overwrite-instructions`: replace existing `.blueprint-oss/instructions/*` files.
- `--overwrite-standards`: replace existing `.blueprint-oss/standards/*` files.
- `--claude` (or `--claude-code`): install Claude Code commands/agents to `./.claude/`.
- `--cursor`: convert commands into Cursor rules under `./.cursor/rules/`.
- `--codex`: copy commands as Codex prompts to `~/.codex/prompts` (non‑destructive; skips existing files).
- `--project-type=TYPE`: select a project type configured in `config.yml` (defaults to `default_project_type`).

## Example installs:

```bash
# Minimal project bootstrap
~/.blueprint-oss/setup/project.sh

# Install with Claude Code + Cursor rules
~/.blueprint-oss/setup/project.sh --claude --cursor

# Add Codex prompts (written to your home dir)
~/.blueprint-oss/setup/project.sh --codex

# Overwrite existing instruction/standards in the target project
~/.blueprint-oss/setup/project.sh --overwrite-instructions --overwrite-standards

# Use a specific project type defined in config.yml
~/.blueprint-oss/setup/project.sh --project-type=generic
```

## How It Works

- The installer copies instruction and standards files into the target repo under `.blueprint-oss/`.
- It can also install optional tooling integrations:
  - Claude Code: copies `commands/` and `agents/` to `./.claude/`.
  - Cursor: converts `commands/*.md` to `.mdc` rules in `./.cursor/rules/`.
  - Codex: copies `commands/*.md` to `~/.codex/prompts` and appends a short “fail‑early if missing file” note.
- Behavior is driven by flags and by defaults in `config.yml` (auto‑enables tools when `enabled: true`).

Nothing in the installer commits changes; it only writes files to your working tree or (for Codex) to your home directory.

## Repository Layout

```
agents/                 Agent guides used by IDE/assistant setups
commands/               Task commands that map to prompts/rules
instructions/core/      Core execution playbooks (flow-oriented)
instructions/meta/      Meta checklists (pre-/post-flight)
standards/              Engineering practices and style guides
setup/project.sh        Installer entrypoint
setup/functions.sh      Shared Bash helper functions
config.yml              Feature flags, defaults, project types
AGENTS.md               Repo guidelines and authoring notes
CLAUDE.md               Claude Code usage notes
```

## Configuration

`config.yml` controls defaults and project types:

- `agents.claude_code.enabled`, `agents.cursor.enabled`, `agents.codex.enabled`: auto‑enable installations when `true`.
- `default_project_type`: selects which instructions/standards source to use by default.
- `project_types`: map of types to instruction/standards source paths.

The installer reads `default_project_type` and can be overridden per run with `--project-type=...`.

## Usage in IDEs and Agents

- Claude Code: prompts available via `/analyze-product`, `/create-spec`, `/execute-tasks`, etc., after `--claude` install.
- Cursor: rules accessible via `@analyze-product`, `@plan-product`, etc., after `--cursor` install.
- Codex: prompts installed to `~/.codex/prompts` after `--codex`; existing files are never overwritten.

The same command names exist across integrations to keep the workflow consistent.

## Development

- Validate shell scripts:

  ```bash
  bash -n setup/*.sh
  # optional: shellcheck setup/*.sh
  ```

- Verify docs and links:

  ```bash
  # find relative Markdown links for quick verification
  grep -R "\[[^]]*\](\([^h][^)]*\))" -n .
  ```

- Dry‑run installer:

  ```bash
  ~/.blueprint-oss/setup/project.sh --help
  mkdir -p /tmp/blueprint-test && cd /tmp/blueprint-test && cp -R ~/.blueprint-oss/setup . && ./setup/project.sh
  ```

## Shell Alias

- Add a handy alias so you can run the installer as `blue` from any project.
- The script detects your shell (bash, zsh, or fish) and appends the alias to the right rc file.

Run:

```bash
bash ./setup/install-alias.sh
```

What it does:

- Creates an alias named `blue` that points to `~/.blueprint-oss/setup/project.sh`.
- Writes to `~/.zshrc` (zsh), `~/.bashrc` or `~/.bash_profile`/`~/.profile` (bash), or `~/.config/fish/config.fish` (fish).
- Idempotent: if the alias already exists in the file, it won’t duplicate it.

Customize:

```bash
# choose alias name and/or target explicitly
bash ./setup/install-alias.sh --alias bp --target ~/.blueprint-oss/setup/project.sh
```

After it runs, either restart your terminal or source the file it updated (the script prints the exact command).

## Conventions

- Commits: follow Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`). Keep one logical change per commit.
- PRs: include purpose, linked issues, affected paths (`instructions/core/*`, etc.), and a short before/after example.
- Style: see `standards/code-style.md` and `standards/code-style/language-style.md` for guidance; wrap Markdown at ~100 columns.
- Filenames: prefer kebab‑case and `.md` for docs (e.g., `create-spec.md`).

## Extending

- New agent: add `agents/<name>.md` with purpose, inputs, outputs, and an example prompt. If used by installers, keep names aligned with references in `setup/project.sh`.
- New command: add `commands/<name>.md`; follow the tone/structure of existing files.
- Project types: define under `project_types` in `config.yml` and point to the desired instruction/standards sources.

## Safety Notes

- The installer writes within the current repository’s working tree (and `~/.codex/prompts` when `--codex` is used). It does not run `git` commands.
- Use `--overwrite-*` flags deliberately; otherwise, existing files are preserved.

---

Questions or suggestions? Open an issue or start a discussion in your hosting VCS.
