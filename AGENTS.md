# Repository Guidelines

This repository hosts blueprint assets used to bootstrap projects and AI agents. Follow these guidelines to add or modify commands, instructions, standards, and setup scripts safely and consistently.

## Project Structure & Module Organization

- `.blueprint-oss/` root (this repo): authoring source.
- `commands/`: CLI-usable command docs (e.g., `plan-product.md`).
- `instructions/core/` and `instructions/meta/`: execution playbooks and checklists.
- `standards/`: engineering practices (`best-practices.md`, `code-style/`, `language-style.md`, `tech-stack.md`).
- `setup/`: installer scripts (`project.sh`, `functions.sh`).
- `agents/`: agent guides (e.g., `file-creator.md`).
- `config.yml`: feature flags and defaults.

## Build, Test, and Development Commands

- `./setup/project.sh --help`: show installer options.
- `./setup/project.sh --overwrite-instructions --overwrite-standards --claude-code --cursor`: install into a target project’s `.blueprint-oss/`, `.claude/`, `.cursor/`.
- `./setup/project.sh --codex`: install Codex prompts to `~/.codex/prompts` (non‑destructive).
- `bash -n setup/*.sh`: syntax‑check shell scripts.
- `grep -R "\[[^]]*\](\([^h][^)]*\))" -n .`: find relative Markdown links for quick verification.

## Coding Style & Naming Conventions

- Markdown: concise, imperative voice; prefer lists; wrap at ~100 cols. See `standards/language-style.md` and `standards/code-style.md`.
- Filenames: kebab‑case, `.md` (e.g., `create-spec.md`). Place core flows in `instructions/core/`, meta checklists in `instructions/meta/`, agents in `agents/`.
- YAML: 2‑space indent; keep keys lowercase; example: `default_project_type: default` in `config.yml`.
- Shell: Bash with `set -e`; keep functions in `setup/functions.sh`.

## Testing Guidelines

- Docs: build locally by opening `.md` files; ensure examples run. Validate links and anchors before PR.
- Shell: `bash -n` for syntax; if available, run `shellcheck setup/*.sh`.
- Changes to installer lists (commands/agents) must be exercised with a dry run: `./setup/project.sh --help` and then a local install in a temp directory.

## Commit & Pull Request Guidelines

- Commits: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`). One logical change per commit.
- PRs: include purpose, linked issues, affected paths (e.g., `instructions/core/*`), and before/after examples (command output or snippet). Keep diffs minimal; avoid unrelated edits.

## Agent-Specific Instructions

- New agent: add `agents/<name>.md` with purpose, inputs, outputs, and example prompt. Keep naming aligned with any references in `setup/project.sh` if adding to the default install list.
- New command: add `commands/<name>.md`; mirror tone and structure of existing files.
- Codex prompts: created in `~/.codex/prompts` from each file in `commands/` and appended with: "If the file does not exist fail early and let the user know." Existing files are skipped; no overwrites.
