#!/usr/bin/env bash
set -e

# Blueprint OSS Update Script
# Updates existing Blueprint OSS installations with new/modified files

# Source the functions library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TARGET_DIR=""
INSTALL_DIR=""
BLUEPRINT_DIR=".blueprint-oss"
BACKUP_SUFFIX=".backup-$(date +%Y%m%d-%H%M%S)"

# Flags
FORCE_UPDATE=false
DRY_RUN=false
VERBOSE=false
AUTO_YES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --install-dir|-i)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --force)
            FORCE_UPDATE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            cat << EOF
Blueprint OSS Update Script

Usage: $0 [TARGET_DIR] [OPTIONS]

Updates an existing Blueprint OSS installation with new or modified files.

Options:
  -i, --install-dir DIR  Specify the Blueprint OSS installation directory
                         (default: auto-detect or .blueprint-oss)
  --force                Force update all files without prompting
  --dry-run              Show what would be updated without making changes
  --verbose,-v           Show detailed output
  --yes,-y               Automatically answer yes to all prompts
  --help,-h              Show this help message

Examples:
  $0                           # Update current directory (auto-detect)
  $0 ~/my-project              # Update specific project
  $0 -i .my-blueprint          # Update with custom install directory
  $0 --dry-run                 # Preview changes without updating
  $0 --force                   # Update all files without prompting

Auto-detection looks for Blueprint OSS in:
  - .blueprint-oss (default)
  - .blueprint
  - blueprint
  - Any directory containing 'instructions' and 'standards' folders

EOF
            exit 0
            ;;
        *)
            if [[ -z "$TARGET_DIR" ]]; then
                TARGET_DIR="$1"
            fi
            shift
            ;;
    esac
done

# Set default target directory to current if not specified
TARGET_DIR="${TARGET_DIR:-.}"

# Resolve target directory
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Target directory '$TARGET_DIR' does not exist${NC}"
    exit 1
}

# Function to detect Blueprint OSS installation
detect_blueprint_install() {
    local search_dir="$1"

    # Check common locations first
    local common_dirs=(".blueprint-oss" ".blueprint" "blueprint")

    for dir in "${common_dirs[@]}"; do
        if [[ -d "$search_dir/$dir/instructions" ]] && [[ -d "$search_dir/$dir/standards" ]]; then
            echo "$dir"
            return 0
        fi
    done

    # Search one level deep for any directory with instructions and standards
    for dir in "$search_dir"/*; do
        if [[ -d "$dir/instructions" ]] && [[ -d "$dir/standards" ]]; then
            echo "$(basename "$dir")"
            return 0
        fi
    done

    return 1
}

# Determine the Blueprint installation directory
if [[ -n "$INSTALL_DIR" ]]; then
    # User specified install directory
    BLUEPRINT_DIR="$INSTALL_DIR"
    echo -e "${BLUE}Using specified installation directory: $BLUEPRINT_DIR${NC}"
else
    # Auto-detect installation
    echo -e "${BLUE}Auto-detecting Blueprint OSS installation...${NC}"

    if detected_dir=$(detect_blueprint_install "$TARGET_DIR"); then
        BLUEPRINT_DIR="$detected_dir"
        echo -e "${GREEN}✓ Found Blueprint OSS in: $BLUEPRINT_DIR${NC}"
    else
        echo -e "${RED}Error: Could not find Blueprint OSS installation in $TARGET_DIR${NC}"
        echo -e "${YELLOW}Searched for directories containing 'instructions' and 'standards' folders.${NC}"
        echo
        echo "Please specify the installation directory with -i or --install-dir:"
        echo "  $0 -i .my-blueprint"
        echo
        echo "Or run './setup/project.sh' to install Blueprint OSS first."
        exit 1
    fi
fi

# Final check if Blueprint OSS is installed
if [[ ! -d "$TARGET_DIR/$BLUEPRINT_DIR" ]]; then
    echo -e "${RED}Error: Blueprint OSS directory not found at $TARGET_DIR/$BLUEPRINT_DIR${NC}"
    exit 1
fi

# Verify it's a valid Blueprint installation
if [[ ! -d "$TARGET_DIR/$BLUEPRINT_DIR/instructions" ]] || [[ ! -d "$TARGET_DIR/$BLUEPRINT_DIR/standards" ]]; then
    echo -e "${RED}Error: Invalid Blueprint OSS installation at $TARGET_DIR/$BLUEPRINT_DIR${NC}"
    echo "Missing required 'instructions' or 'standards' directories."
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}             Blueprint OSS Update Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo

# Function to compare files using checksums
files_differ() {
    local source_file="$1"
    local target_file="$2"

    if [[ ! -f "$target_file" ]]; then
        return 0  # Target doesn't exist, files differ
    fi

    # Use md5 on macOS, md5sum on Linux
    if command -v md5 > /dev/null; then
        local source_hash=$(md5 -q "$source_file" 2>/dev/null)
        local target_hash=$(md5 -q "$target_file" 2>/dev/null)
    else
        local source_hash=$(md5sum "$source_file" 2>/dev/null | cut -d' ' -f1)
        local target_hash=$(md5sum "$target_file" 2>/dev/null | cut -d' ' -f1)
    fi

    [[ "$source_hash" != "$target_hash" ]]
}

# Function to prompt for update
prompt_update() {
    local file="$1"
    local action="$2"  # "new", "modified", or "different"

    if [[ "$AUTO_YES" == true ]] || [[ "$FORCE_UPDATE" == true ]]; then
        return 0
    fi

    local prompt_msg
    case "$action" in
        new)
            prompt_msg="Add new file: $file?"
            ;;
        modified)
            prompt_msg="Update modified file: $file?"
            ;;
        different)
            prompt_msg="File has local changes: $file. Overwrite?"
            ;;
    esac

    echo -en "${YELLOW}$prompt_msg [y/N]: ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Function to show diff preview
show_diff() {
    local source_file="$1"
    local target_file="$2"

    if [[ "$VERBOSE" == true ]] && [[ -f "$target_file" ]]; then
        echo -e "${BLUE}Changes for $(basename "$source_file"):${NC}"
        # Show first 10 lines of diff
        diff -u "$target_file" "$source_file" 2>/dev/null | head -20 || true
        echo
    fi
}

# Function to update a file
update_file() {
    local source_file="$1"
    local target_file="$2"
    local rel_path="$3"

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${GREEN}[DRY RUN] Would update: $rel_path${NC}"
        return 0
    fi

    # Create backup if file exists
    if [[ -f "$target_file" ]]; then
        cp "$target_file" "${target_file}${BACKUP_SUFFIX}"
        [[ "$VERBOSE" == true ]] && echo -e "${BLUE}  Backed up to: $(basename "${target_file}${BACKUP_SUFFIX}")${NC}"
    fi

    # Create directory if needed
    mkdir -p "$(dirname "$target_file")"

    # Copy the file
    cp "$source_file" "$target_file"
    echo -e "${GREEN}✓ Updated: $rel_path${NC}"
}

# Collect all files to check
echo -e "${BLUE}Scanning for updates...${NC}"
echo

# Categories of files to update
declare -a new_files=()
declare -a modified_files=()
declare -a unchanged_files=()
declare -a skipped_files=()

# Define source directories to sync
SOURCE_DIRS=(
    "commands"
    "instructions/core"
    "instructions/meta"
    "standards"
    "agents"
)

# Add individual files
SOURCE_FILES=(
    "config.yml"
    "CLAUDE.md"
    "README.md"
)

# Check directories
for dir in "${SOURCE_DIRS[@]}"; do
    if [[ -d "$SCRIPT_DIR/../$dir" ]]; then
        while IFS= read -r -d '' source_file; do
            # Skip non-markdown and non-yaml files
            if [[ ! "$source_file" =~ \.(md|yml|yaml)$ ]]; then
                continue
            fi

            # Calculate relative path
            rel_path="${source_file#$SCRIPT_DIR/../}"
            target_file="$TARGET_DIR/$BLUEPRINT_DIR/$rel_path"

            if [[ ! -f "$target_file" ]]; then
                new_files+=("$rel_path")
            elif files_differ "$source_file" "$target_file"; then
                modified_files+=("$rel_path")
            else
                unchanged_files+=("$rel_path")
            fi
        done < <(find "$SCRIPT_DIR/../$dir" -type f -print0 2>/dev/null)
    fi
done

# Check individual files
for file in "${SOURCE_FILES[@]}"; do
    source_file="$SCRIPT_DIR/../$file"
    if [[ -f "$source_file" ]]; then
        target_file="$TARGET_DIR/$BLUEPRINT_DIR/$file"

        if [[ ! -f "$target_file" ]]; then
            new_files+=("$file")
        elif files_differ "$source_file" "$target_file"; then
            modified_files+=("$file")
        else
            unchanged_files+=("$file")
        fi
    fi
done

# Display summary
echo -e "${BLUE}Update Summary:${NC}"
echo -e "  ${GREEN}New files: ${#new_files[@]}${NC}"
echo -e "  ${YELLOW}Modified files: ${#modified_files[@]}${NC}"
echo -e "  ${BLUE}Unchanged files: ${#unchanged_files[@]}${NC}"
echo

# Process new files
if [[ ${#new_files[@]} -gt 0 ]]; then
    echo -e "${GREEN}New files to add:${NC}"
    for file in "${new_files[@]}"; do
        echo "  - $file"
    done
    echo

    if prompt_update "all new files" "new"; then
        for file in "${new_files[@]}"; do
            source_file="$SCRIPT_DIR/../$file"
            target_file="$TARGET_DIR/$BLUEPRINT_DIR/$file"
            update_file "$source_file" "$target_file" "$file"
        done
    else
        # Ask for each file individually
        for file in "${new_files[@]}"; do
            source_file="$SCRIPT_DIR/../$file"
            target_file="$TARGET_DIR/$BLUEPRINT_DIR/$file"

            if prompt_update "$file" "new"; then
                update_file "$source_file" "$target_file" "$file"
            else
                skipped_files+=("$file")
            fi
        done
    fi
    echo
fi

# Process modified files
if [[ ${#modified_files[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Modified files to update:${NC}"
    for file in "${modified_files[@]}"; do
        echo "  - $file"
    done
    echo

    for file in "${modified_files[@]}"; do
        source_file="$SCRIPT_DIR/../$file"
        target_file="$TARGET_DIR/$BLUEPRINT_DIR/$file"

        show_diff "$source_file" "$target_file"

        if prompt_update "$file" "modified"; then
            update_file "$source_file" "$target_file" "$file"
        else
            skipped_files+=("$file")
        fi
    done
    echo
fi

# Handle special integrations (.claude, .cursor)
echo -e "${BLUE}Checking integrations...${NC}"

# Update .claude/CLAUDE.md if it exists
if [[ -f "$TARGET_DIR/.claude/CLAUDE.md" ]]; then
    source_file="$SCRIPT_DIR/../CLAUDE.md"
    target_file="$TARGET_DIR/.claude/CLAUDE.md"

    if files_differ "$source_file" "$target_file"; then
        echo -e "${YELLOW}Found changes in .claude/CLAUDE.md${NC}"
        show_diff "$source_file" "$target_file"

        if prompt_update ".claude/CLAUDE.md" "modified"; then
            update_file "$source_file" "$target_file" ".claude/CLAUDE.md"
        fi
    fi
fi

# Update .cursor/cursorrules if it exists
if [[ -f "$TARGET_DIR/.cursor/cursorrules" ]]; then
    source_file="$SCRIPT_DIR/../CLAUDE.md"
    target_file="$TARGET_DIR/.cursor/cursorrules"

    if files_differ "$source_file" "$target_file"; then
        echo -e "${YELLOW}Found changes in .cursor/cursorrules${NC}"
        show_diff "$source_file" "$target_file"

        if prompt_update ".cursor/cursorrules" "modified"; then
            update_file "$source_file" "$target_file" ".cursor/cursorrules"
        fi
    fi
fi

# Final summary
echo
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    Update Complete${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}This was a dry run. No files were actually modified.${NC}"
else
    update_count=$((${#new_files[@]} + ${#modified_files[@]} - ${#skipped_files[@]}))
    echo -e "${GREEN}✓ Updated $update_count file(s)${NC}"

    if [[ ${#skipped_files[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠ Skipped ${#skipped_files[@]} file(s)${NC}"
    fi

    if [[ ${#unchanged_files[@]} -gt 0 ]]; then
        echo -e "${BLUE}ℹ ${#unchanged_files[@]} file(s) already up to date${NC}"
    fi
fi

echo
echo -e "${BLUE}Backup files (if any) have suffix: ${BACKUP_SUFFIX}${NC}"