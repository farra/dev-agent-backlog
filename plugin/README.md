# Backlog Plugin for Claude Code

Design doc driven task management for human-agent collaboration.

## Installation

This plugin is designed for **project scope** installation. It assumes a specific
project structure (`backlog.org`, `docs/design/`, etc.) that you'll create via setup.

```bash
# Add the marketplace
/plugin marketplace add farra/dev-agent-backlog

# Install the plugin (project scope recommended)
/plugin install backlog@dev-agent-backlog --scope project
```

### Installation Scopes

| Scope | Recommended? | Notes |
|-------|--------------|-------|
| `--scope project` | Yes | Shared with collaborators via `.claude/settings.json` |
| `--scope local` | OK | Just you, just this repo |
| `--scope user` | No | Would trigger in every project, even without setup |

**Why not user scope?** The skills (like `backlog-update`) trigger on common actions
like commits. Without a `backlog.org` in the project, they'll fail or be confusing.
Project scope ensures the plugin only activates where it's been set up.

## Quick Start

After installing, set up your project:

```bash
# Say this to Claude, or use the setup skill
"Set up design docs for this project"

# Or invoke directly
/backlog:setup
```

The setup will:
1. Ask for your project prefix (e.g., `ACME`)
2. Create the directory structure
3. Write template files
4. Update your CLAUDE.md

## Commands

| Command | Description |
|---------|-------------|
| `/backlog:setup` | Initialize design doc system in a project |
| `/backlog:new-design-doc <title>` | Create a new design document |
| `/backlog:task-queue <id>` | Queue a task from design doc to backlog |
| `/backlog:task-start <id>` | Begin work on a task |
| `/backlog:task-complete <id>` | Mark a task as done |
| `/backlog:task-hold <id> <reason>` | Move task to blocked |
| `/backlog:queue-design-doc <doc>` | Queue all tasks from a design doc |
| `/backlog:design-review <doc>` | Guide doc through review workflow |

## Skills (Auto-triggered)

| Skill | Triggers when... |
|-------|------------------|
| `backlog-resume` | Session starts with WIP tasks |
| `backlog-update` | Before commits, reminds to update backlog |
| `new-design-doc` | Architectural discussions suggest creating a doc |
| `setup` | User wants to initialize design doc system |

## Workflow

```
                        backlog.org (hub)
                              │
         ┌────────────┬───────┴───────┬────────────┐
         ▼            ▼               ▼            ▼
    Design Doc    Claude Task    GitHub Issue    Bead
    :DESIGN:      :CLAUDE_TASK:  :GITHUB:        :BEAD:
```

1. **backlog.org** is a human-readable hub linking to tasks wherever they live
2. Tasks can originate from design docs, GitHub issues, or Claude Tasks
3. Link properties (`:DESIGN:`, `:GITHUB:`, etc.) connect to canonical sources
4. Completed tasks are reconciled back to their source

## Task ID Format

```
[PREFIX-NNN-XX]
   │      │   └── Task sequence (01, 02, ...)
   │      └────── Design doc number
   └───────────── Project prefix (e.g., ACME, GF)
```

## Files Created by Setup

| File | Purpose |
|------|---------|
| `README.org` | Project config (prefix, categories, statuses) |
| `org-setup.org` | Shared org-mode configuration |
| `backlog.org` | Working surface for active tasks |
| `CHANGELOG.md` | Release changelog |
| `docs/design/README.org` | Index of design documents |
| `docs/design/000-template.org` | Template for new design docs |

## Methodology

This plugin implements a methodology that works with any AI coding agent:

- **Design docs**: RFC/RFD-style documents capturing decisions and tasks
- **Backlog**: Ephemeral working surface (not a permanent record)
- **Task checkout**: Copy tasks to backlog, track progress, reconcile when done
- **Handoff notes**: `:HANDOFF:` property for session-to-session context

The org-mode files work regardless of which agent you use. The plugin just makes the workflow smoother in Claude Code.

## Learn More

- [Design Doc Pattern](https://github.com/farra/dev-agent-backlog/blob/main/docs/design/002-design-docs.org)
- [Backlog Workflow](https://github.com/farra/dev-agent-backlog/blob/main/docs/design/003-backlog-workflow.org)
- [Full Documentation](https://github.com/farra/dev-agent-backlog)
