#!/usr/bin/env bash
#
# Initialize dev-agent-backlog in a project
#
# Usage: ./init.sh [options] <project-prefix> [target-dir]
#
# Options:
#   -f, --force    Bypass safety checks and run in a non-empty directory.
#   -h, --help     Show this help message.
#
# Example:
#   ./init.sh GF ~/dev/gongfu
#   ./init.sh MYAPP .
#

set -euo pipefail

# =============================================================================
# DEPRECATION NOTICE
# =============================================================================
# This script is deprecated. Use the Claude Code plugin instead:
#
#   /plugin marketplace add farra/dev-agent-backlog
#   /plugin install backlog@dev-agent-backlog
#
# Then in your project:
#   /backlog:setup
#
# The plugin provides an interactive setup experience and auto-updating.
# This script will be removed in a future release.
# =============================================================================

echo ""
echo "WARNING: init.sh is deprecated."
echo ""
echo "Use the Claude Code plugin instead:"
echo "  /plugin marketplace add farra/dev-agent-backlog"
echo "  /plugin install backlog@dev-agent-backlog"
echo ""
echo "Then run: /backlog:setup"
echo ""
echo "Continuing with legacy install in 3 seconds..."
echo "(Press Ctrl+C to cancel)"
sleep 3
echo ""

usage() {
    # Print the script's header comments, stopping at the first non-comment line.
    sed '/^#/!q' "$0" | grep '^#[^!]' | cut -c3-
    exit 1
}

FORCE=false
ARGS=()

# Process flags first
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        # A '--' signals the end of options
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

# --- Configuration ---

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# NEW: Check for mandatory project-prefix
if [[ ${#ARGS[@]} -eq 0 ]]; then
    echo "Error: Missing <project-prefix> argument." >&2
    echo "" >&2
    usage
fi

# Positional arguments
PREFIX="${ARGS[0]}"
TARGET="${ARGS[1]:-.}"

# Resolve target to absolute path
TARGET="$(cd "$TARGET" && pwd)"

# --- Pre-flight Checks & User Feedback ---

echo "Initializing dev-agent-backlog with the following settings:"
echo "  Project prefix:   $PREFIX"
echo "  Target directory: $TARGET"
echo ""

# Check if target directory is empty, unless --force is used
if ! $FORCE && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
    echo "Warning: Target directory '$TARGET' is not empty."
    read -p "    Running this script will copy new directories and files to this directory. Continue? [y/N] " -n 1 -r
    echo # Move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Initialization cancelled."
        exit 1
    fi
    echo "" # Add a blank line for spacing after confirmation
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p "$TARGET/docs/design"
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/skills/backlog-update"
mkdir -p "$TARGET/.claude/skills/backlog-resume"
mkdir -p "$TARGET/.claude/skills/new-design-doc"

# Copy org-setup.org
echo "Copying org-setup.org..."
cp "$SCRIPT_DIR/templates/org-setup.org" "$TARGET/org-setup.org"

# Copy backlog template
echo "Creating backlog.org..."
sed "s/PROJECT/$PREFIX/g" "$SCRIPT_DIR/templates/backlog-template.org" > "$TARGET/backlog.org"

# Copy design doc template
echo "Creating docs/design/000-template.org..."
sed "s/PROJECT/$PREFIX/g" "$SCRIPT_DIR/templates/design-doc-template.org" > "$TARGET/docs/design/000-template.org"

# Create README.org (project config with categories/statuses)
echo "Creating README.org..."
sed "s/PROJECT/$PREFIX/g" "$SCRIPT_DIR/templates/readme-project.org" > "$TARGET/README.org"

# Create README.org for design docs
echo "Creating docs/design/README.org..."
cp "$SCRIPT_DIR/templates/readme-design.org" "$TARGET/docs/design/README.org"

# Create CHANGELOG.md
echo "Creating CHANGELOG.md..."
cp "$SCRIPT_DIR/templates/changelog-template.md" "$TARGET/CHANGELOG.md"

# Copy Claude commands
echo "Copying Claude Code commands..."
for cmd in task-queue task-complete task-hold task-start new-design-doc queue-design-doc; do
    if [[ -f "$SCRIPT_DIR/.claude/commands/$cmd.md" ]]; then
        sed "s/PROJECT/$PREFIX/g" "$SCRIPT_DIR/.claude/commands/$cmd.md" > "$TARGET/.claude/commands/$cmd.md"
    fi
done

# Copy Claude skills
echo "Copying Claude Code skills..."
for skill in backlog-update backlog-resume new-design-doc; do
    if [[ -d "$SCRIPT_DIR/.claude/skills/$skill" ]]; then
        mkdir -p "$TARGET/.claude/skills/$skill"
        for file in "$SCRIPT_DIR/.claude/skills/$skill"/*; do
            if [[ -f "$file" ]]; then
                sed "s/PROJECT/$PREFIX/g" "$file" > "$TARGET/.claude/skills/$skill/$(basename "$file")"
            fi
        done
    fi
done

echo ""
echo "Done! Created:"
echo "  $TARGET/README.org"
echo "  $TARGET/org-setup.org"
echo "  $TARGET/backlog.org"
echo "  $TARGET/CHANGELOG.md"
echo "  $TARGET/docs/design/README.org"
echo "  $TARGET/docs/design/000-template.org"
echo "  $TARGET/.claude/commands/"
echo "  $TARGET/.claude/skills/"
echo ""
echo "Next steps:"
echo "  1. Review org-setup.org and customize tags"
echo "  2. Create your first design doc:"
echo "     /new-design-doc Your First Feature"
echo "  3. Start tracking work in backlog.org"
echo ""
echo "For Emacs users, add to your config:"
echo "  (load \"$TARGET/elisp/workflow-commands.el\")"
