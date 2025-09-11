#!/bin/bash

# blueprint Project Installation Script
# This script installs blueprint in a project directory

set -e  # Exit on error

# Initialize flags
OVERWRITE_INSTRUCTIONS=false
OVERWRITE_STANDARDS=false
CLAUDE_CODE=false
CURSOR=false
CODEX=false
PROJECT_TYPE=""
CUSTOM_INSTALL_DIR=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --overwrite-instructions)
            OVERWRITE_INSTRUCTIONS=true
            shift
            ;;
        --overwrite-standards)
            OVERWRITE_STANDARDS=true
            shift
            ;;
        --claude-code|--claude|--claude_code)
            CLAUDE_CODE=true
            shift
            ;;
        --cursor|--cursor-cli)
            CURSOR=true
            shift
            ;;
        --codex|--codex-cli)
            CODEX=true
            shift
            ;;
        --project-type=*)
            PROJECT_TYPE="${1#*=}"
            shift
            ;;
        -i|--install-dir)
            CUSTOM_INSTALL_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --overwrite-instructions    Overwrite existing instruction files"
            echo "  --overwrite-standards       Overwrite existing standards files"
            echo "  --claude-code               Add Claude Code support"
            echo "  --cursor                    Add Cursor support"
            echo "  --codex                     Add Codex support (writes to ~/.codex/prompts)"
            echo "  --project-type=TYPE         Use specific project type for installation"
            echo "  --install-dir=DIR, -i DIR   Custom installation directory (default: .blueprint-oss)"
            echo "  -h, --help                  Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo ""
echo "🚀 blueprint Project Installation"
echo "================================"
echo ""

# Get project directory info
CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")
if [ -n "$CUSTOM_INSTALL_DIR" ]; then
    INSTALL_DIR="$CUSTOM_INSTALL_DIR"
else
    INSTALL_DIR="./.blueprint-oss"
fi

echo "📍 Installing blueprint to this project's root directory ($PROJECT_NAME)"
echo ""

# Get the base blueprint directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_BLUEPRINT="$(dirname "$SCRIPT_DIR")"
echo "✓ Using blueprint base installation at $BASE_BLUEPRINT"
# Source shared functions from base installation
source "$SCRIPT_DIR/functions.sh"

# Export CUSTOM_INSTALL_DIR so functions can access it
export CUSTOM_INSTALL_DIR

echo ""
echo "📁 Creating project directories..."
echo ""
mkdir -p "$INSTALL_DIR"

# Auto-enable tools based on base config if no flags provided
if [ "$CLAUDE_CODE" = false ]; then
    # Check if claude_code is enabled in base config
    if grep -q "claude_code:" "$BASE_BLUEPRINT/config.yml" && \
        grep -A1 "claude_code:" "$BASE_BLUEPRINT/config.yml" | grep -q "enabled: true"; then
        CLAUDE_CODE=true
        echo "  ✓ Auto-enabling Claude Code support (from blueprint config)"
    fi
fi

if [ "$CURSOR" = false ]; then
    # Check if cursor is enabled in base config
    if grep -q "cursor:" "$BASE_BLUEPRINT/config.yml" && \
        grep -A1 "cursor:" "$BASE_BLUEPRINT/config.yml" | grep -q "enabled: true"; then
        CURSOR=true
        echo "  ✓ Auto-enabling Cursor support (from blueprint config)"
    fi
fi

if [ "$CODEX" = false ]; then
    # Check if codex is enabled in base config
    if grep -q "codex:" "$BASE_BLUEPRINT/config.yml" && \
        grep -A1 "codex:" "$BASE_BLUEPRINT/config.yml" | grep -q "enabled: true"; then
        CODEX=true
        echo "  ✓ Auto-enabling Codex support (from blueprint config)"
    fi
fi

# Read project type from config or use flag
if [ -z "$PROJECT_TYPE" ] && [ -f "$BASE_BLUEPRINT/config.yml" ]; then
    # Try to read default_project_type from config
    PROJECT_TYPE=$(grep "^default_project_type:" "$BASE_BLUEPRINT/config.yml" | cut -d' ' -f2 | tr -d ' ')
    if [ -z "$PROJECT_TYPE" ]; then
        PROJECT_TYPE="default"
    fi
elif [ -z "$PROJECT_TYPE" ]; then
    PROJECT_TYPE="default"
fi

echo ""
echo "📦 Using project type: $PROJECT_TYPE"

# Determine source paths based on project type
INSTRUCTIONS_SOURCE=""
STANDARDS_SOURCE=""

if [ "$PROJECT_TYPE" = "default" ]; then
    INSTRUCTIONS_SOURCE="$BASE_BLUEPRINT/instructions"
    STANDARDS_SOURCE="$BASE_BLUEPRINT/standards"
else
    # Look up project type in config
    if grep -q "^  $PROJECT_TYPE:" "$BASE_BLUEPRINT/config.yml"; then
        # Extract paths for this project type
        INSTRUCTIONS_PATH=$(awk "/^  $PROJECT_TYPE:/{f=1} f&&/instructions:/{print \$2; exit}" "$BASE_BLUEPRINT/config.yml")
        STANDARDS_PATH=$(awk "/^  $PROJECT_TYPE:/{f=1} f&&/standards:/{print \$2; exit}" "$BASE_BLUEPRINT/config.yml")

        # Expand tilde in paths
        INSTRUCTIONS_SOURCE=$(eval echo "$INSTRUCTIONS_PATH")
        STANDARDS_SOURCE=$(eval echo "$STANDARDS_PATH")

        # Check if paths exist
        if [ ! -d "$INSTRUCTIONS_SOURCE" ] || [ ! -d "$STANDARDS_SOURCE" ]; then
            echo "  ⚠️  Project type '$PROJECT_TYPE' paths not found, falling back to default instructions and standards"
            INSTRUCTIONS_SOURCE="$BASE_BLUEPRINT/instructions"
            STANDARDS_SOURCE="$BASE_BLUEPRINT/standards"
        fi
    else
        echo "  ⚠️  Project type '$PROJECT_TYPE' not found in config, using default instructions and standards"
        INSTRUCTIONS_SOURCE="$BASE_BLUEPRINT/instructions"
        STANDARDS_SOURCE="$BASE_BLUEPRINT/standards"
    fi
fi

# Copy instructions and standards from determined sources
echo ""
echo "📥 Installing instruction files to $INSTALL_DIR/instructions/"
copy_directory "$INSTRUCTIONS_SOURCE" "$INSTALL_DIR/instructions" "$OVERWRITE_INSTRUCTIONS"

echo ""
echo "📥 Installing standards files to $INSTALL_DIR/standards/"
copy_directory "$STANDARDS_SOURCE" "$INSTALL_DIR/standards" "$OVERWRITE_STANDARDS"


# Handle Claude Code installation for project
if [ "$CLAUDE_CODE" = true ]; then
    echo ""
    echo "📥 Installing Claude Code support..."
    mkdir -p "./.claude/commands"
    mkdir -p "./.claude/agents"

    # Copy from base installation
    echo "  📂 Commands:"
    for cmd in "$BASE_BLUEPRINT"/commands/*.md; do
        [ -f "$cmd" ] || continue
        filename=$(basename "$cmd")
        copy_file "$cmd" "./.claude/commands/$filename" "false" "commands/$filename"
    done

    echo ""
    echo "  📂 Agents:"
    for agent in "$BASE_BLUEPRINT"/agents/*.md; do
        [ -f "$agent" ] || continue
        filename=$(basename "$agent")
        copy_file "$agent" "./.claude/agents/$filename" "false" "agents/$filename"
    done
fi

# Handle Cursor installation for project
if [ "$CURSOR" = true ]; then
    echo ""
    echo "📥 Installing Cursor support..."
    mkdir -p "./.cursor/rules"

    echo "  📂 Rules:"

    # Iterate all command markdown files
    # Convert commands from base installation to Cursor rules
    for cmd in "$BASE_BLUEPRINT"/commands/*.md; do
        [ -f "$cmd" ] || continue
        filename=$(basename "$cmd" .md)
        convert_to_cursor_rule "$cmd" "./.cursor/rules/${filename}.mdc"
    done
fi

# Handle Codex installation for project (prompts in user home)
if [ "$CODEX" = true ]; then
    echo ""
    echo "📥 Installing Codex support..."
    DEST_DIR="$HOME/.codex/prompts"
    mkdir -p "$DEST_DIR"

    echo "  📂 Prompts:"
    # Iterate all command markdown files
    for cmd in "$BASE_BLUEPRINT"/commands/*.md; do
        [ -f "$cmd" ] || continue
        base="$(basename "$cmd")"
        create_codex_prompt "$cmd" "$DEST_DIR/$base"
    done
fi

# Success message
echo ""
echo "✅ blueprint has been installed in your project ($PROJECT_NAME)!"
echo ""
echo "📍 Project-level files installed to:"
echo "   .blueprint-oss/instructions/    - blueprint instructions"
echo "   .blueprint-oss/standards/       - Development standards"

if [ "$CLAUDE_CODE" = true ]; then
    echo "   .claude/commands/          - Claude Code commands"
    echo "   .claude/agents/            - Claude Code specialized agents"
fi

if [ "$CURSOR" = true ]; then
    echo "   .cursor/rules/             - Cursor command rules"
fi

if [ "$CODEX" = true ]; then
    echo "   ~/.codex/prompts/          - Codex prompts (user home)"
fi

echo ""
echo "--------------------------------"
echo ""
echo "Next steps:"
echo ""

if [ "$CLAUDE_CODE" = true ]; then
    echo "Claude Code usage:"
    echo "  /analyze-product      - Set up the mission and roadmap for an existing product"
    echo "  /create-priority-item - Create a priority item for a new feature"
    echo "  /create-spec          - Create a spec for a new feature"
    echo "  /execute-tasks        - Build and ship code for a new feature"
    echo "  /revise-spec          - Revise and enhance an existing spec"
    echo "  /plan-product         - Set the mission & roadmap for a new product"
    echo "  /update-roadmap       - Update the roadmap for a product"
    echo ""
fi

if [ "$CURSOR" = true ]; then
    echo "Cursor usage:"
    echo "  @analyze-product      - Set up the mission and roadmap for an existing product"
    echo "  @create-priority-item - Create a priority item for a new feature"
    echo "  @create-spec          - Create a spec for a new feature"
    echo "  @execute-tasks        - Build and ship code for a new feature"
    echo "  @revise-spec          - Revise and enhance an existing spec"
    echo "  @plan-product         - Set the mission & roadmap for a new product"
    echo "  @update-roadmap       - Update the roadmap for a product"
    echo ""
fi

if [ "$CODEX" = true ]; then
    echo "Codex prompts:"
    echo "  Installed to ~/.codex/prompts (non-destructive, skip on exist)"
    echo "  Usage:"
    echo "    /analyze-product      - Set up the mission and roadmap for an existing product"
    echo "    /create-priority-item - Create a priority item for a new feature"
    echo "    /create-spec          - Create a spec for a new feature"
    echo "    /execute-tasks        - Build and ship code for a new feature"
    echo "    /revise-spec          - Revise and enhance an existing spec"
    echo "    /plan-product         - Set the mission & roadmap for a new product"
    echo "    /update-roadmap       - Update the roadmap for a product"
    echo ""
fi
