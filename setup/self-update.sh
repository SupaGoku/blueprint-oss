#!/usr/bin/env bash
set -e

# Blueprint OSS Self-Update Script
# Updates the Blueprint OSS repository itself from git

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the script directory (where Blueprint OSS is installed)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
FORCE_UPDATE=false
DRY_RUN=false
VERBOSE=false
STASH_CHANGES=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
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
        --no-stash)
            STASH_CHANGES=false
            shift
            ;;
        --help|-h)
            cat << EOF
Blueprint OSS Self-Update Script

Usage: $0 [OPTIONS]

Updates the Blueprint OSS repository from its git remote.

Options:
  --force       Force update even with uncommitted changes
  --dry-run     Show what would be done without making changes
  --verbose,-v  Show detailed git output
  --no-stash    Don't stash local changes (may cause conflicts)
  --help,-h     Show this help message

Examples:
  $0                    # Update Blueprint OSS repository
  $0 --dry-run          # Preview what would happen
  $0 --force            # Force update with local changes

Notes:
  - Requires git to be installed
  - Must be run from within the Blueprint OSS repository
  - Will stash local changes by default (restored after update)
  - After update, run 'blue-update' to update your projects

EOF
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}            Blueprint OSS Self-Update Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo

# Check if we're in a git repository
if ! git -C "$REPO_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Blueprint OSS directory is not a git repository${NC}"
    echo -e "${YELLOW}Path: $REPO_DIR${NC}"
    echo
    echo "To enable self-updates, clone Blueprint OSS from git:"
    echo "  git clone https://github.com/yourusername/blueprint-oss.git ~/.blueprint-oss"
    exit 1
fi

cd "$REPO_DIR"

# Get current branch and remote
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_REMOTE=$(git config --get "branch.${CURRENT_BRANCH}.remote" || echo "origin")
DEFAULT_BRANCH=$(git config --get "branch.${CURRENT_BRANCH}.merge" | sed 's|refs/heads/||' || echo "$CURRENT_BRANCH")

echo -e "${CYAN}Repository: $REPO_DIR${NC}"
echo -e "${CYAN}Remote: $DEFAULT_REMOTE${NC}"
echo -e "${CYAN}Branch: $CURRENT_BRANCH${NC}"
echo

# Check for uncommitted changes
if [[ "$FORCE_UPDATE" != true ]] && [[ "$DRY_RUN" != true ]]; then
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"

        if [[ "$STASH_CHANGES" == true ]]; then
            echo -e "${BLUE}Changes will be stashed and restored after update${NC}"
        else
            echo -e "${RED}Error: Uncommitted changes detected${NC}"
            echo "Options:"
            echo "  1. Commit your changes first"
            echo "  2. Use --force to update anyway"
            echo "  3. Use --no-stash at your own risk"
            exit 1
        fi
        echo
    fi
fi

# Function to run git commands
run_git() {
    local cmd="$1"

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY RUN] Would run: git $cmd${NC}"
        return 0
    fi

    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}Running: git $cmd${NC}"
        git $cmd
    else
        git $cmd 2>&1 | grep -v "Already up to date" || true
    fi
}

# Stash changes if needed
STASHED=false
if [[ "$STASH_CHANGES" == true ]] && [[ "$DRY_RUN" != true ]]; then
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${BLUE}Stashing local changes...${NC}"
        run_git "stash push -m 'Blueprint OSS self-update stash $(date +%Y%m%d-%H%M%S)'"
        STASHED=true
    fi
fi

# Fetch latest changes
echo -e "${BLUE}Fetching latest changes from $DEFAULT_REMOTE...${NC}"
run_git "fetch $DEFAULT_REMOTE"

# Check if there are updates
LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse "$DEFAULT_REMOTE/$DEFAULT_BRANCH" 2>/dev/null || echo "")

if [[ -z "$REMOTE_HASH" ]]; then
    echo -e "${YELLOW}Warning: Could not find remote branch $DEFAULT_REMOTE/$DEFAULT_BRANCH${NC}"
    echo "This might be the first fetch or the branch doesn't exist on remote yet."

    # Restore stashed changes if any
    if [[ "$STASHED" == true ]]; then
        echo -e "${BLUE}Restoring stashed changes...${NC}"
        run_git "stash pop"
    fi

    exit 0
fi

if [[ "$LOCAL_HASH" == "$REMOTE_HASH" ]]; then
    echo -e "${GREEN}✓ Blueprint OSS is already up to date${NC}"

    # Restore stashed changes if any
    if [[ "$STASHED" == true ]]; then
        echo -e "${BLUE}Restoring stashed changes...${NC}"
        run_git "stash pop"
    fi

    exit 0
fi

# Show what's new
echo -e "${BLUE}New commits available:${NC}"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}[DRY RUN] Would show commits from $LOCAL_HASH to $REMOTE_HASH${NC}"
else
    git log --oneline "$LOCAL_HASH..$REMOTE_HASH" | head -10

    TOTAL_COMMITS=$(git rev-list --count "$LOCAL_HASH..$REMOTE_HASH")
    if [[ $TOTAL_COMMITS -gt 10 ]]; then
        echo -e "${CYAN}... and $((TOTAL_COMMITS - 10)) more commits${NC}"
    fi
fi
echo

# Perform the update
echo -e "${BLUE}Updating Blueprint OSS...${NC}"

# Try fast-forward merge first
if run_git "merge --ff-only $DEFAULT_REMOTE/$DEFAULT_BRANCH" 2>/dev/null; then
    echo -e "${GREEN}✓ Successfully updated via fast-forward merge${NC}"
else
    # If fast-forward fails, try regular merge
    echo -e "${YELLOW}Fast-forward not possible, attempting regular merge...${NC}"

    if [[ "$FORCE_UPDATE" == true ]] || [[ "$DRY_RUN" == true ]]; then
        run_git "merge $DEFAULT_REMOTE/$DEFAULT_BRANCH"
        echo -e "${GREEN}✓ Successfully merged updates${NC}"
    else
        echo -e "${RED}Error: Cannot fast-forward, manual intervention may be required${NC}"
        echo "Your local branch has diverged from the remote."
        echo "Options:"
        echo "  1. Review and merge manually"
        echo "  2. Use --force to attempt automatic merge"

        # Restore stashed changes if any
        if [[ "$STASHED" == true ]]; then
            echo -e "${BLUE}Restoring stashed changes...${NC}"
            run_git "stash pop"
        fi

        exit 1
    fi
fi

# Restore stashed changes if any
if [[ "$STASHED" == true ]]; then
    echo -e "${BLUE}Restoring stashed changes...${NC}"

    if ! run_git "stash pop" 2>/dev/null; then
        echo -e "${YELLOW}Warning: Could not automatically restore stashed changes${NC}"
        echo "Your changes are safe in the stash. To restore manually:"
        echo "  git stash list  # See all stashes"
        echo "  git stash pop   # Apply the latest stash"
    fi
fi

# Show summary
echo
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                  Self-Update Complete${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}This was a dry run. No changes were actually made.${NC}"
else
    NEW_HASH=$(git rev-parse HEAD)
    echo -e "${GREEN}✓ Updated from ${LOCAL_HASH:0:7} to ${NEW_HASH:0:7}${NC}"
    echo
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Review the changes with: git log -p HEAD@{1}..HEAD"
    echo "  2. Update your projects with: blue-update"
    echo "  3. Reinstall aliases if needed: ./setup/install-alias.sh"
fi