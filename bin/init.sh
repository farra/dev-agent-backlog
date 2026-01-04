#!/usr/bin/env bash
#
# Initialize dev-agent-backlog in a project
#
# Usage: ./init.sh [project-prefix] [target-dir]
#
# Example:
#   ./init.sh GF ~/dev/gongfu
#   ./init.sh MYAPP .
#

set -euo pipefail

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Arguments
PREFIX="${1:-PROJECT}"
TARGET="${2:-.}"

# Resolve target to absolute path
TARGET="$(cd "$TARGET" && pwd)"

echo "Initializing dev-agent-backlog..."
echo "  Project prefix: $PREFIX"
echo "  Target directory: $TARGET"
echo ""

# Create directory structure
echo "Creating directory structure..."
mkdir -p "$TARGET/docs/design"
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/skills/backlog-update"
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

# Create README.org for design docs
echo "Creating docs/design/README.org..."
cat > "$TARGET/docs/design/README.org" << 'HEREDOC'
#+TITLE: Design Documents
#+SETUPFILE: ../../org-setup.org

* Overview

This directory contains design documents following an RFC/RFD pattern.
Each document captures a decision, its rationale, and implementation tasks.

* Document Status

| Status       | Meaning                      |
|--------------+------------------------------|
| Draft        | Under development            |
| Discussion   | Ready for review             |
| Accepted     | Approved, ready to implement |
| Implementing | Implementation in progress   |
| Complete     | Implemented and verified     |
| Abandoned    | Stopped, not viable          |

* Documents

| Doc | Title      | Status |
|-----+------------+--------|
| 000 | [[file:000-template.org][Template]]   | N/A    |

* Numbering

| Range   | Category           |
|---------+--------------------|
| 001-099 | Core system        |
| 100-199 | Features           |
| 200-299 | Infrastructure     |
| 300-399 | Tooling            |
| 800-899 | Analysis/Research  |
| 900-999 | Proposals/Future   |
HEREDOC

# Copy Claude commands
echo "Copying Claude Code commands..."
for cmd in task-queue task-complete task-hold task-start new-design-doc; do
    if [[ -f "$SCRIPT_DIR/.claude/commands/$cmd.md" ]]; then
        sed "s/PROJECT/$PREFIX/g" "$SCRIPT_DIR/.claude/commands/$cmd.md" > "$TARGET/.claude/commands/$cmd.md"
    fi
done

# Copy Claude skills
echo "Copying Claude Code skills..."
for skill in backlog-update new-design-doc; do
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
echo "  $TARGET/org-setup.org"
echo "  $TARGET/backlog.org"
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
