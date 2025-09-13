#!/usr/bin/env bash

# Install convenient shell aliases for blueprint OSS
# Adds: alias blue='~/.blueprint-oss/setup/project.sh'
#       alias blue-update='~/.blueprint-oss/setup/update.sh'
#       alias blue-self-update='~/.blueprint-oss/setup/self-update.sh'

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: install-alias.sh [--alias <name>] [--target <path>] [--shell <bash|zsh|fish>] [--dry-run] [--verbose]

Options:
  --alias <name>   Primary alias name to create (default: blue)
  --target <path>  Target script path (default: ~/.blueprint-oss/setup/project.sh)
  --shell <name>   Override detected shell (bash|zsh|fish). Default: from $SHELL
  --dry-run        Print actions without writing files
  --verbose        Show detailed shell detection information
  -h, --help       Show this help

The installer appends idempotent aliases to your shell rc file:
  - bash: Intelligently detects the correct file based on sourcing patterns
  - zsh:  ~/.zshrc
  - fish: ~/.config/fish/config.fish (adds function wrappers)

Creates three aliases:
  - <name>             : Install/setup Blueprint OSS (default: blue)
  - <name>-update      : Update existing Blueprint OSS installations
  - <name>-self-update : Update the Blueprint OSS repository itself

After installation, restart your terminal or source the file it updated.
USAGE
}

ALIAS_NAME="blue"
TARGET_DEFAULT="$HOME/.blueprint-oss/setup/project.sh"
UPDATE_TARGET_DEFAULT="$HOME/.blueprint-oss/setup/update.sh"
SELF_UPDATE_TARGET_DEFAULT="$HOME/.blueprint-oss/setup/self-update.sh"
TARGET="$TARGET_DEFAULT"
UPDATE_TARGET="$UPDATE_TARGET_DEFAULT"
SELF_UPDATE_TARGET="$SELF_UPDATE_TARGET_DEFAULT"
OVERRIDE_SHELL=""
DRY_RUN=false
VERBOSE=false

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
    --verbose)
      VERBOSE=true; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

# Normalize targets to absolute paths for writing
TARGET_EXPANDED=$(eval echo "$TARGET")
UPDATE_TARGET_EXPANDED=$(eval echo "$UPDATE_TARGET")
SELF_UPDATE_TARGET_EXPANDED=$(eval echo "$SELF_UPDATE_TARGET")

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

# Function to check if a file sources another
file_sources() {
  local file="$1"
  local target="$2"

  if [[ ! -f "$file" ]]; then
    return 1
  fi

  # Check for common sourcing patterns
  if grep -qE "(source|\.)\s+[\"']?.*$(basename "$target")[\"']?" "$file" 2>/dev/null; then
    return 0
  fi

  return 1
}

# Function to determine the best RC file for bash
find_bash_rc() {
  local preferred_file=""
  local verbose_log=""

  # Check if .bash_profile exists and what it sources
  if [[ -f "$HOME/.bash_profile" ]]; then
    verbose_log="${verbose_log}  Found: .bash_profile\n"
    # Check if it sources .profile
    if file_sources "$HOME/.bash_profile" ".profile"; then
      if [[ -f "$HOME/.profile" ]]; then
        verbose_log="${verbose_log}    → sources .profile (using .profile)\n"
        preferred_file="$HOME/.profile"
      else
        verbose_log="${verbose_log}    → sources .profile (but .profile not found, using .bash_profile)\n"
        preferred_file="$HOME/.bash_profile"
      fi
    # Check if it sources .bashrc
    elif file_sources "$HOME/.bash_profile" ".bashrc"; then
      if [[ -f "$HOME/.bashrc" ]]; then
        verbose_log="${verbose_log}    → sources .bashrc (using .bashrc)\n"
        preferred_file="$HOME/.bashrc"
      else
        verbose_log="${verbose_log}    → sources .bashrc (but .bashrc not found, using .bash_profile)\n"
        preferred_file="$HOME/.bash_profile"
      fi
    else
      verbose_log="${verbose_log}    → doesn't source other files (using .bash_profile)\n"
      preferred_file="$HOME/.bash_profile"
    fi
  fi

  # Check if .profile exists and what it sources
  if [[ -z "$preferred_file" ]] && [[ -f "$HOME/.profile" ]]; then
    verbose_log="${verbose_log}  Found: .profile\n"
    # Check if it sources .bashrc
    if file_sources "$HOME/.profile" ".bashrc"; then
      if [[ -f "$HOME/.bashrc" ]]; then
        verbose_log="${verbose_log}    → sources .bashrc (using .bashrc)\n"
        preferred_file="$HOME/.bashrc"
      else
        verbose_log="${verbose_log}    → sources .bashrc (but .bashrc not found, using .profile)\n"
        preferred_file="$HOME/.profile"
      fi
    else
      verbose_log="${verbose_log}    → doesn't source other files (using .profile)\n"
      preferred_file="$HOME/.profile"
    fi
  fi

  # If still no preferred file, check .bashrc
  if [[ -z "$preferred_file" ]] && [[ -f "$HOME/.bashrc" ]]; then
    verbose_log="${verbose_log}  Found: .bashrc\n"
    # Check if .bashrc is empty or nearly empty (just comments/whitespace)
    local content_lines=$(grep -v '^\s*#' "$HOME/.bashrc" | grep -v '^\s*$' | wc -l)
    if [[ $content_lines -le 1 ]]; then
      verbose_log="${verbose_log}    → appears empty ($content_lines non-comment lines)\n"
      # Prefer .bash_profile or .profile if they exist
      if [[ -f "$HOME/.bash_profile" ]]; then
        verbose_log="${verbose_log}    → using .bash_profile instead\n"
        preferred_file="$HOME/.bash_profile"
      elif [[ -f "$HOME/.profile" ]]; then
        verbose_log="${verbose_log}    → using .profile instead\n"
        preferred_file="$HOME/.profile"
      else
        verbose_log="${verbose_log}    → using .bashrc anyway (no alternatives)\n"
        preferred_file="$HOME/.bashrc"
      fi
    else
      verbose_log="${verbose_log}    → has content ($content_lines non-comment lines, using .bashrc)\n"
      preferred_file="$HOME/.bashrc"
    fi
  fi

  # Final fallback
  if [[ -z "$preferred_file" ]]; then
    verbose_log="${verbose_log}  No existing files found, using fallback order:\n"
    if [[ -f "$HOME/.bash_profile" ]]; then
      verbose_log="${verbose_log}    → .bash_profile exists (using it)\n"
      preferred_file="$HOME/.bash_profile"
    elif [[ -f "$HOME/.profile" ]]; then
      verbose_log="${verbose_log}    → .profile exists (using it)\n"
      preferred_file="$HOME/.profile"
    else
      verbose_log="${verbose_log}    → defaulting to .bashrc\n"
      preferred_file="$HOME/.bashrc"
    fi
  fi

  if [[ "$VERBOSE" == true ]] && [[ -n "$verbose_log" ]]; then
    echo "Shell configuration analysis for bash:" >&2
    echo -e "$verbose_log" >&2
    echo "  Selected: $preferred_file" >&2
    echo >&2
  fi

  echo "$preferred_file"
}

RC_FILE=""
RELOAD_CMD=""

case "$DETECTED_SHELL" in
  zsh)
    RC_FILE="$HOME/.zshrc"
    RELOAD_CMD="source \"$RC_FILE\"" ;;
  bash)
    RC_FILE=$(find_bash_rc)
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
echo "Alias names:    $ALIAS_NAME, ${ALIAS_NAME}-update, ${ALIAS_NAME}-self-update"
echo "Target scripts: $TARGET_EXPANDED"
echo "                $UPDATE_TARGET_EXPANDED"
echo "                $SELF_UPDATE_TARGET_EXPANDED"
echo "RC file:        $RC_FILE"

# Build content per shell for all aliases
if [[ "$DETECTED_SHELL" == "fish" ]]; then
  ALIAS_LINE="function $ALIAS_NAME; \"$TARGET_EXPANDED\" \$argv; end"
  UPDATE_ALIAS_LINE="function ${ALIAS_NAME}-update; \"$UPDATE_TARGET_EXPANDED\" \$argv; end"
  SELF_UPDATE_ALIAS_LINE="function ${ALIAS_NAME}-self-update; \"$SELF_UPDATE_TARGET_EXPANDED\" \$argv; end"
else
  ALIAS_LINE="alias $ALIAS_NAME='\"$TARGET_EXPANDED\"'"
  UPDATE_ALIAS_LINE="alias ${ALIAS_NAME}-update='\"$UPDATE_TARGET_EXPANDED\"'"
  SELF_UPDATE_ALIAS_LINE="alias ${ALIAS_NAME}-self-update='\"$SELF_UPDATE_TARGET_EXPANDED\"'"
fi

# Ensure rc file exists
ensure_dir "$(dirname "$RC_FILE")"
[[ -f "$RC_FILE" ]] || { [[ "$DRY_RUN" == true ]] || touch "$RC_FILE"; }

# Install all aliases
append_once "$RC_FILE" "$ALIAS_LINE"
append_once "$RC_FILE" "$UPDATE_ALIAS_LINE"
append_once "$RC_FILE" "$SELF_UPDATE_ALIAS_LINE"

echo
echo "✅ Installed aliases:"
echo "   $ALIAS_NAME             : Install/setup Blueprint OSS"
echo "   ${ALIAS_NAME}-update      : Update existing Blueprint OSS installations"
echo "   ${ALIAS_NAME}-self-update : Update the Blueprint OSS repository"
echo
echo "   Usage: $ALIAS_NAME --help"
echo "   Usage: ${ALIAS_NAME}-update --help"
echo "   Usage: ${ALIAS_NAME}-self-update --help"
echo "   Reload: $RELOAD_CMD  (or restart your terminal)"

