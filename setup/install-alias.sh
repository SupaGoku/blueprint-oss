#!/usr/bin/env bash

# Install a convenient shell alias for blueprint OSS
# Adds: alias <name>='~/.blueprint-oss/setup/project.sh' to the appropriate rc file

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: install-alias.sh [--alias <name>] [--target <path>] [--shell <bash|zsh|fish>] [--dry-run]

Options:
  --alias <name>   Alias name to create (default: blue)
  --target <path>  Target script path (default: ~/.blueprint-oss/setup/project.sh)
  --shell <name>   Override detected shell (bash|zsh|fish). Default: from $SHELL
  --dry-run        Print actions without writing files
  -h, --help       Show this help

The installer appends an idempotent alias to your shell rc file:
  - bash: ~/.bashrc (or ~/.bash_profile / ~/.profile fallback)
  - zsh:  ~/.zshrc
  - fish: ~/.config/fish/config.fish (adds a function wrapper)

After installation, restart your terminal or source the file it updated.
USAGE
}

ALIAS_NAME="blue"
TARGET_DEFAULT="$HOME/.blueprint-oss/setup/project.sh"
TARGET="$TARGET_DEFAULT"
OVERRIDE_SHELL=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --alias)
      [[ $# -ge 2 ]] || { echo "--alias requires a value" >&2; exit 1; }
      ALIAS_NAME="$2"; shift 2 ;;
    --target)
      [[ $# -ge 2 ]] || { echo "--target requires a value" >&2; exit 1; }
      TARGET="$2"; shift 2 ;;
    --shell)
      [[ $# -ge 2 ]] || { echo "--shell requires a value" >&2; exit 1; }
      OVERRIDE_SHELL="$2"; shift 2 ;;
    --dry-run)
      DRY_RUN=true; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

# Normalize target to absolute path for writing
TARGET_EXPANDED=$(eval echo "$TARGET")

# Detect shell
DETECTED_SHELL=${OVERRIDE_SHELL:-"${SHELL##*/}"}
DETECTED_SHELL=$(echo "$DETECTED_SHELL" | tr 'A-Z' 'a-z')

date_stamp() { date +%Y-%m-%d; }

ensure_dir() {
  local d="$1"
  [[ "$DRY_RUN" == true ]] && { echo "DRY-RUN mkdir -p $d"; return; }
  mkdir -p "$d"
}

append_once() {
  local file="$1"; shift
  local content="$*"
  if [[ -f "$file" ]] && grep -Fqs "$content" "$file"; then
    echo "✓ Alias already present in $file"
    return 0
  fi
  local header="# blueprint OSS alias for '$ALIAS_NAME' (added $(date_stamp))"
  echo "→ Updating $file"
  if [[ "$DRY_RUN" == true ]]; then
    printf '\n%s\n%s\n' "$header" "$content"
  else
    {
      printf '\n%s\n' "$header"
      printf '%s\n' "$content"
    } >> "$file"
  fi
}

RC_FILE=""
RELOAD_CMD=""

case "$DETECTED_SHELL" in
  zsh)
    RC_FILE="$HOME/.zshrc"
    RELOAD_CMD="source \"$RC_FILE\"" ;;
  bash)
    if [[ -f "$HOME/.bashrc" ]]; then
      RC_FILE="$HOME/.bashrc"
    elif [[ -f "$HOME/.bash_profile" ]]; then
      RC_FILE="$HOME/.bash_profile"
    elif [[ -f "$HOME/.profile" ]]; then
      RC_FILE="$HOME/.profile"
    else
      RC_FILE="$HOME/.bashrc"
    fi
    RELOAD_CMD="source \"$RC_FILE\"" ;;
  fish)
    ensure_dir "$HOME/.config/fish"
    RC_FILE="$HOME/.config/fish/config.fish"
    RELOAD_CMD="source \"$RC_FILE\"" ;;
  *)
    # Fallback to POSIX profile
    RC_FILE="$HOME/.profile"
    RELOAD_CMD=". \"$RC_FILE\"" ;;
esac

echo "Detected shell: $DETECTED_SHELL"
echo "Alias name:     $ALIAS_NAME"
echo "Target script:  $TARGET_EXPANDED"
echo "RC file:        $RC_FILE"

# Build content per shell
if [[ "$DETECTED_SHELL" == "fish" ]]; then
  ALIAS_LINE="function $ALIAS_NAME; \"$TARGET_EXPANDED\" \$argv; end"
else
  ALIAS_LINE="alias $ALIAS_NAME='\"$TARGET_EXPANDED\"'"
fi

# Ensure rc file exists
ensure_dir "$(dirname "$RC_FILE")"
[[ -f "$RC_FILE" ]] || { [[ "$DRY_RUN" == true ]] || touch "$RC_FILE"; }

append_once "$RC_FILE" "$ALIAS_LINE"

echo
echo "✅ Installed alias: $ALIAS_NAME"
echo "   Use: $ALIAS_NAME --help"
echo "   Reload: $RELOAD_CMD  (or restart your terminal)"

