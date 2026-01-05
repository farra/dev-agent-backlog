# dev-agent-backlog

A task management system designed for human-agent collaboration, combining emacs org-mode design documents, a backlog working surface, and Claude Code integration.

## Why This Exists

Traditional task management (GitHub Issues, Jira, Linear) is designed for human-to-human collaboration. When AI coding agents enter the workflow, these systems create friction:

| Challenge        | Traditional Systems             | dev-agent-backlog          |
|------------------|---------------------------------|----------------------------|
| Context locality | Issue separate from design docs | Task lives in design doc   |
| Atomic updates   | API call separate from code     | File change in same commit |
| API friction     | Auth, rate limits, network      | Direct file read/write     |
| Source of truth  | Issue is primary                | Design doc is primary      |

This system treats **design documents as the source of truth**. Tasks exist because of design decisions. The backlog is a working surface, not the canonical record.

## Components

```
your-project/
├── org-setup.org          # Shared org-mode configuration
├── backlog.org            # Working surface for active tasks
├── CHANGELOG.md           # User-facing change log
├── docs/
│   └── design/
│       ├── README.org     # Index of design docs
│       ├── 000-template.org
│       ├── 001-feature.org
│       └── ...
└── .claude/
    ├── commands/          # Slash commands
    │   ├── task-queue.md
    │   ├── task-start.md
    │   ├── task-complete.md
    │   ├── task-hold.md
    │   ├── new-design-doc.md
    │   └── queue-design-doc.md
    └── skills/
        ├── backlog-update/
        ├── backlog-resume/
        └── new-design-doc/
```

### Design Documents

Org-mode files following an RFC/RFD pattern:
- Each document captures a decision and its rationale
- Tasks defined inline with `** TODO [ID]` headings
- Questions tracked with `** OPEN` / `** DECIDED`

### Backlog

A single `backlog.org` serving as the active working surface:
- Tasks "checked out" from design docs
- Progress notes accumulate during work
- Completed tasks "reconciled" back to design docs

### Agent Integration

Claude Code slash commands:
- `/task-queue <id>` - Check out a task from design doc to backlog
- `/task-start <id>` - Begin work with context and handoff notes
- `/task-complete <id> [version]` - Reconcile completed task with attribution
- `/task-hold <id> <reason>` - Move task to blocked
- `/new-design-doc <title>` - Create a new design document
- `/queue-design-doc <doc>` - Queue all tasks from a design doc

Proactive skills:
- `backlog-update` - Reminds to update backlog and changelog before commits
- `backlog-resume` - Surfaces WIP tasks and handoff notes on session start
- `new-design-doc` - Suggests creating design docs during architecture discussions

## The Workflow

```
Design Doc                    Backlog
┌──────────────────┐          ┌──────────────────┐
│ ** TODO [ID]     │─checkout→│ *** TODO [ID]    │
│                  │          │ :SOURCE: link    │
└──────────────────┘          │ progress notes   │
                              └────────┬─────────┘
                                       │ work
                                       ▼
                              ┌──────────────────┐
                              │ *** DONE [ID]    │
                              └────────┬─────────┘
                                       │ reconcile
                                       ▼
┌──────────────────┐          ┌──────────────────┐
│ ** DONE [ID]     │←─────────│ (removed)        │
│ :VERSION: v1.0   │          └──────────────────┘
└──────────────────┘
```

1. **Checkout**: Copy task to backlog Active section with `:SOURCE:` link
2. **Work**: Add progress notes under the task
3. **Reconcile**: Mark DONE in design doc, remove from backlog

## Getting Started

### Quick Start (Bootstrap Script)

```bash
# Clone or download dev-agent-backlog
git clone https://github.com/farra/dev-agent-backlog.git

# Initialize your project
./dev-agent-backlog/bin/init.sh MYPREFIX ~/path/to/your-project

# Example for a project called "acme-api":
./dev-agent-backlog/bin/init.sh ACME ~/dev/acme-api
```

The init script creates:
- `org-setup.org` - Shared org-mode configuration
- `backlog.org` - Working surface for active tasks
- `docs/design/README.org` - Design doc index
- `docs/design/000-template.org` - Template for new design docs
- `.claude/commands/` - Slash commands for Claude Code
- `.claude/skills/` - Proactive skills for Claude Code

### Manual Installation

If you prefer to copy files manually:

```bash
cp templates/org-setup.org your-project/
cp templates/backlog-template.org your-project/backlog.org
mkdir -p your-project/docs/design
cp templates/design-doc-template.org your-project/docs/design/000-template.org
cp -r .claude your-project/
# Then edit files to replace PROJECT with your prefix
```

### Customize org-setup.org

Edit the tags for your project:

```org
#+TAGS: p0 p1 p2 | frontend backend infra
```

### Create Your First Design Doc

Use the slash command:
```
/new-design-doc Your Feature Name
```

Or manually:
```bash
cp docs/design/000-template.org docs/design/001-first-feature.org
```

### Start Using the Workflow

With Claude Code:
```
/task-queue PROJECT-001-01
/task-start PROJECT-001-01
# ... do the work ...
/task-complete PROJECT-001-01 v1.0
```

With Emacs:
- Position on a task heading
- `M-x dab-task-queue` to check out
- Edit backlog.org for progress notes
- Manually reconcile when done

## For Emacs Users

Add to your config:

```elisp
;; Load the task queue command
(load "path/to/your-project/elisp/workflow-commands.el")

;; Optional: bind to a key
(define-key org-mode-map (kbd "C-c q") #'dab-task-queue)
```

See `backlog.org` Setup section for agenda configuration.

## For Claude Code Users

The `.claude/` directory contains:
- **Slash commands**: Explicit actions you invoke
- **Skills**: Proactive behaviors Claude offers

### Slash Commands

| Command | Description |
|---------|-------------|
| `/task-queue <id>` | Check out a task from design doc to backlog Active section |
| `/task-start <id>` | Begin work: gather context, display handoff notes, update attribution |
| `/task-complete <id> [version]` | Mark done with attribution, prompt for changelog entry |
| `/task-hold <id> <reason>` | Move task to Blocked section with reason |
| `/new-design-doc <title>` | Create a new design document from template |
| `/queue-design-doc <doc>` | Queue all tasks from a design doc with pre-flight checks |

### Skills

| Skill | Trigger | Behavior |
|-------|---------|----------|
| `backlog-resume` | Session start | Checks for WIP tasks, surfaces handoff notes |
| `backlog-update` | Before commits | Reminds to update backlog, changelog, and handoff notes |
| `new-design-doc` | Architecture discussions | Suggests creating design docs |

### Task Properties

Tasks in the backlog track:
- `:SOURCE:` - Link to canonical location in design doc
- `:HANDOFF:` - Notes for next session (what to try, where stuck)
- `:WORKED_BY:` - Who has worked on this (claude-code, human)

Completed tasks in design docs also include:
- `:COMPLETED_BY:` - Who marked it done
- `:TRANSCRIPT:` - Link to Claude conversation transcript

## Task ID Format

```
[PROJECT-NNN-XX]
   │      │   │
   │      │   └── Task sequence (01, 02, ...)
   │      └────── Design doc number (001, 002, ...)
   └───────────── Project prefix (DAB, GF, ...)
```

## Document Numbering

| Range   | Category          |
|---------|-------------------|
| 000     | Template          |
| 001-099 | Core system       |
| 100-199 | Features          |
| 200-299 | Infrastructure    |
| 300-399 | Tooling           |
| 800-899 | Analysis/Research |
| 900-999 | Proposals/Future  |

## Comparison with Other Systems

### vs GitHub Issues

| Aspect              | GitHub Issues   | dev-agent-backlog     |
|---------------------|-----------------|-----------------------|
| Agent efficiency    | API calls, auth | Direct file access    |
| Context             | Sparse, linked  | Inline in design docs |
| Atomic commits      | No              | Yes                   |
| External visibility | Excellent       | Requires repo access  |

**Best for**: Small teams, agent-heavy workflows, design-driven development.

### vs Jira/Linear

| Aspect        | Jira/Linear   | dev-agent-backlog |
|---------------|---------------|-------------------|
| Overhead      | High (web UI) | Low (text files)  |
| Customization | Limited       | Unlimited         |
| Cost          | Paid tiers    | Free              |

**Best for**: Teams that value simplicity and agent integration over enterprise features.

## Philosophy

- **Design docs as source of truth**: Tasks exist because of design decisions
- **Working surface pattern**: Backlog is ephemeral; design docs are permanent
- **Atomic operations**: Task state and code versioned together
- **Plain text everything**: Git history is task history

## Prior Art

This system evolved from [dev-agent-work](https://github.com/farra/dev-agent-work), an earlier experiment in agent-friendly task management. Key improvements in this version:

- Design docs as canonical source (not standalone task files)
- Checkout/reconcile workflow (vs direct task editing)
- Richer org-mode integration (queries, agenda views)
- Structured slash commands and skills

## License

Apache 2

## Contributing

This system documents itself using itself. See `docs/design/` for the design documents and `backlog.org` for current work.
