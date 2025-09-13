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
  - Use `blue-update` to intelligently update existing Blueprint OSS installations
  - Use `blue-self-update` to pull the latest changes from the Blueprint OSS repository
  - To force overwrite files, use `--overwrite-instructions` and/or `--overwrite-standards`
  - To add IDE/agent support later, re-run with `--claude`, `--cursor`, and/or `--codex`

## Quick Start

### Step 1: Install Blueprint OSS (one-time setup)

Clone the Blueprint OSS repository to your home directory:

```bash
git clone git@github.com-supagoku:SupaGoku/blueprint-oss.git ~/.blueprint-oss
```

### Step 2: Install the Shell Aliases (recommended)

This creates convenient shortcuts so you don't have to type the full path every time:

```bash
~/.blueprint-oss/setup/install-alias.sh
```

This installs three commands:

- `blue` - Install/setup Blueprint OSS in projects
- `blue-update` - Update existing Blueprint OSS installations in projects
- `blue-self-update` - Update the Blueprint OSS repository itself

**Important:** After installing aliases, either:

- Restart your terminal, OR
- Run the source command shown by the installer (e.g., `source ~/.profile`)

### Step 3: Install Blueprint into Your Project

Navigate to your project directory and run:

```bash
blue  # If you installed the alias
# OR
~/.blueprint-oss/setup/project.sh  # Without alias
```

This creates a `.blueprint-oss/` directory in your project with all the instructions and standards.

## Common options:

- `--overwrite-instructions`: replace existing `.blueprint-oss/instructions/*` files.
- `--overwrite-standards`: replace existing `.blueprint-oss/standards/*` files.
- `--claude` (or `--claude-code`): install Claude Code commands/agents to `./.claude/`.
- `--cursor`: convert commands into Cursor rules under `./.cursor/rules/`.
- `--codex`: copy commands as Codex prompts to `~/.codex/prompts` (non‑destructive; skips existing files).
- `--project-type=TYPE`: select a project type configured in `config.yml` (defaults to `default_project_type`).

## Example Commands

### Installation Examples

```bash
# Minimal project bootstrap
blue  # or ~/.blueprint-oss/setup/project.sh

# Install with Claude Code + Cursor rules
blue --claude --cursor

# Add Codex prompts (written to your home dir)
blue --codex

# Overwrite existing instruction/standards in the target project
blue --overwrite-instructions --overwrite-standards

# Use a specific project type defined in config.yml
blue --project-type=generic

# Install to a custom directory (not .blueprint-oss)
blue -i .my-blueprint
```

### Update Examples

```bash
# Update current project (auto-detect installation)
blue-update

# Preview what would be updated
blue-update --dry-run

# Update with detailed change information
blue-update --verbose

# Update without prompts (accept all changes)
blue-update --yes

# Update a custom installation directory
blue-update -i .my-blueprint

# Force update all files
blue-update --force
```

### Self-Update Examples

```bash
# Update Blueprint OSS repository
blue-self-update

# Preview self-update
blue-self-update --dry-run

# Force update with local changes
blue-self-update --force

# See detailed git operations
blue-self-update --verbose
```

## Keeping Blueprint OSS Updated

Blueprint OSS provides three levels of updates to keep your installations current:

### 1. Self-Update: Update the Blueprint OSS Repository

Pulls the latest changes from the Blueprint OSS git repository:

```bash
blue-self-update  # If you have the alias
# OR
~/.blueprint-oss/setup/self-update.sh
```

**What it does:**

- Fetches latest changes from git remote
- Shows new commits before updating
- Automatically stashes and restores your local changes
- Uses fast-forward merge when possible

**Options:**

- `--dry-run` - Preview what would happen without making changes
- `--force` - Force update even with uncommitted changes
- `--verbose` - Show detailed git output
- `--no-stash` - Don't stash local changes (risky)

### 2. Project Update: Update Your Projects

After self-updating, update your project installations:

```bash
blue-update  # If you have the alias
# OR
~/.blueprint-oss/setup/update.sh
```

**What it does:**

- Auto-detects Blueprint OSS installation in your project
- Compares files using checksums to find changes
- Shows you what's new or modified
- Prompts for confirmation before updating each file
- Creates timestamped backups of modified files

**Options:**

- `-i <dir>` or `--install-dir <dir>` - Specify custom installation directory
- `--dry-run` - Preview changes without updating
- `--force` - Update all files without prompting
- `--yes` or `-y` - Automatically answer yes to all prompts
- `--verbose` or `-v` - Show detailed diffs of changes

**Auto-detection looks for Blueprint in:**

- `.blueprint-oss` (default)
- `.blueprint`
- `blueprint`
- Any directory containing both `instructions/` and `standards/` folders

### 3. Complete Update Workflow

**For beginners, here's the complete update process:**

```bash
# Step 1: Update Blueprint OSS itself
blue-self-update

# Step 2: Navigate to your project
cd ~/my-project

# Step 3: Update the project's Blueprint installation
blue-update

# Optional: Preview changes first
blue-update --dry-run

# Optional: See detailed changes
blue-update --verbose
```

## How It Works

- The installer copies instruction and standards files into the target repo under `.blueprint-oss/`.
- It can also install optional tooling integrations:
  - Claude Code: copies `commands/` and `agents/` to `./.claude/`.
  - Cursor: converts `commands/*.md` to `.mdc` rules in `./.cursor/rules/`.
  - Codex: copies `commands/*.md` to `~/.codex/prompts` and appends a short "fail‑early if missing file" note.
- Behavior is driven by flags and by defaults in `config.yml` (auto‑enables tools when `enabled: true`).

Nothing in the installer commits changes; it only writes files to your working tree or (for Codex) to your home directory.

## Repository Layout

```
agents/                 Agent guides used by IDE/assistant setups
commands/               Task commands that map to prompts/rules
instructions/core/      Core execution playbooks (flow-oriented)
instructions/meta/      Meta checklists (pre-/post-flight)
standards/              Engineering practices and style guides
setup/
  project.sh            Main installer (blue)
  update.sh             Project updater (blue-update)
  self-update.sh        Repository updater (blue-self-update)
  install-alias.sh      Shell alias installer
  functions.sh          Shared Bash helper functions
config.yml              Feature flags, defaults, project types
CLAUDE.md               Repository and Claude Code usage notes
README.md               This file
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

## Shell Aliases

The installer creates three convenient aliases for you:

### Installation

```bash
~/.blueprint-oss/setup/install-alias.sh
```

**What it installs:**

- `blue` - Main setup command (runs `~/.blueprint-oss/setup/project.sh`)
- `blue-update` - Update projects (runs `~/.blueprint-oss/setup/update.sh`)
- `blue-self-update` - Update Blueprint OSS (runs `~/.blueprint-oss/setup/self-update.sh`)

### Smart Shell Detection

The installer intelligently detects your shell configuration:

- **For bash:** Analyzes `.bash_profile`, `.profile`, and `.bashrc` to find the right file
- **For zsh:** Uses `.zshrc`
- **For fish:** Uses `.config/fish/config.fish`

**Special bash handling:**

- Detects if `.bash_profile` sources `.profile` (uses `.profile`)
- Detects if `.bash_profile` sources `.bashrc` (uses `.bashrc`)
- Checks if `.bashrc` is empty and uses alternatives
- Handles complex sourcing chains correctly

### Troubleshooting Shell Detection

If aliases aren't working, debug with verbose mode:

```bash
~/.blueprint-oss/setup/install-alias.sh --verbose
```

This shows:

- Which shell config files were found
- Which files source other files
- Why a particular file was chosen
- The exact file that will be modified

### Customization Options

```bash
# Use a different alias name
~/.blueprint-oss/setup/install-alias.sh --alias bp

# Force a specific shell
~/.blueprint-oss/setup/install-alias.sh --shell bash

# Preview without making changes
~/.blueprint-oss/setup/install-alias.sh --dry-run

# Verbose output for debugging
~/.blueprint-oss/setup/install-alias.sh --verbose
```

After installation, either:

1. Restart your terminal, OR
2. Run the source command shown (e.g., `source ~/.profile`)

## Conventions

- Commits: follow Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`). Keep one logical change per commit.
- PRs: include purpose, linked issues, affected paths (`instructions/core/*`, etc.), and a short before/after example.
- Style: see `standards/code-style.md` and `standards/code-style/language-style.md` for guidance; wrap Markdown at ~100 columns.
- Filenames: prefer kebab‑case and `.md` for docs (e.g., `create-spec.md`).

## Extending

- New agent: add `agents/<name>.md` with purpose, inputs, outputs, and an example prompt. If used by installers, keep names aligned with references in `setup/project.sh`.
- New command: add `commands/<name>.md`; follow the tone/structure of existing files.
- Project types: define under `project_types` in `config.yml` and point to the desired instruction/standards sources.

## Troubleshooting

### Common Issues and Solutions

#### Aliases Not Working

**Problem:** After running `install-alias.sh`, the `blue` commands aren't recognized.

**Solutions:**

1. **Restart your terminal** or run the source command shown by the installer
2. **Check verbose output:** Run `~/.blueprint-oss/setup/install-alias.sh --verbose` to see which file was modified
3. **Verify the file was updated:** Check your shell config file (e.g., `cat ~/.profile | grep blue`)
4. **Wrong shell detected:** Force the correct shell with `--shell bash` or `--shell zsh`

#### Blueprint Not Found

**Problem:** `blue-update` says "Blueprint OSS is not installed"

**Solutions:**

1. **Check installation directory:** Blueprint might be in a non-standard location
2. **Specify directory explicitly:** Use `blue-update -i .my-blueprint` if you used a custom directory
3. **Verify installation:** Check if the directory contains `instructions/` and `standards/` folders

#### Git Remote Issues

**Problem:** `blue-self-update` fails with "unknown revision" or similar git errors

**Solutions:**

1. **First time setup:** The remote hasn't been fetched yet. Run `git fetch origin` first
2. **Check remote:** Verify with `git remote -v` that origin points to the correct repository
3. **Network issues:** Check your internet connection and GitHub access

#### Permission Denied

**Problem:** Scripts fail with "permission denied" errors

**Solutions:**

1. **Make scripts executable:** Run `chmod +x ~/.blueprint-oss/setup/*.sh`
2. **Check ownership:** Ensure you own the Blueprint OSS directory
3. **Installation location:** Make sure Blueprint OSS is installed in your home directory, not system directories

#### Updates Not Showing

**Problem:** `blue-update` says everything is up to date but you know there are changes

**Solutions:**

1. **Run self-update first:** Always run `blue-self-update` before `blue-update`
2. **Check git status:** In `~/.blueprint-oss`, run `git status` to see if you're on the right branch
3. **Force update:** Use `blue-update --force` to overwrite all files

#### Shell Config Confusion

**Problem:** Not sure which shell configuration file is being used

**Solutions:**

1. **Use verbose mode:** `~/.blueprint-oss/setup/install-alias.sh --verbose` shows the analysis
2. **Common patterns:**
   - If `.bash_profile` sources `.profile` → aliases go in `.profile`
   - If `.bash_profile` sources `.bashrc` → aliases go in `.bashrc`
   - Empty `.bashrc` → uses `.bash_profile` or `.profile` instead
3. **Manual check:** Look for `source` or `.` commands in your shell files

## Safety Notes

- The installer writes within the current repository's working tree (and `~/.codex/prompts` when `--codex` is used). It does not run `git` commands.
- Use `--overwrite-*` flags deliberately; otherwise, existing files are preserved.
- The update scripts create timestamped backups before modifying files
- Self-update automatically stashes and restores local changes

---

Questions or suggestions? Open an issue
