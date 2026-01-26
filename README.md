# dev-agent-backlog

A task management system designed for human-agent collaboration, using org-mode design documents as the source of truth.

## Installation (Claude Code Plugin)

```bash
# Add the marketplace
/plugin marketplace add farra/dev-agent-backlog

# Install the plugin
/plugin install backlog@dev-agent-backlog
```

Then initialize your project:
```bash
# Interactive setup (recommended)
/backlog:setup

# Or just say: "Set up design docs for this project"
```

> **Other Agents**: The design doc methodology works with any AI coding agent that can read/write files. The org-mode templates and workflow are agent-agnostic. We're exploring adapters for [OpenAI Codex](https://github.com/openai/codex), [Gemini CLI](https://github.com/google-gemini/gemini-cli), and [OpenCode](https://github.com/anomalyco/opencode). Contributions welcome!

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

After running `/backlog:setup`, your project will have:

```
your-project/
├── README.org             # Project config (prefix, categories, statuses)
├── org-setup.org          # Shared org-mode configuration
├── backlog.org            # Working surface for active tasks
├── CHANGELOG.md           # User-facing change log
└── docs/
    └── design/
        ├── README.org     # Index of design docs
        ├── 000-template.org
        ├── 001-feature.org
        └── ...
```

The plugin provides commands and skills - no files installed in your project's `.claude/` directory.

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

Claude Code plugin commands (all prefixed with `backlog:`):
- `/backlog:setup` - Initialize design doc system in a project
- `/backlog:new-design-doc <title>` - Create a new design document
- `/backlog:design-review <doc>` - Review doc: resolve questions, finalize tasks
- `/backlog:queue-design-doc <doc>` - Queue all tasks from a design doc
- `/backlog:task-queue <id>` - Check out a task from design doc to backlog
- `/backlog:task-start <id>` - Begin work with context and handoff notes
- `/backlog:task-complete <id> [version]` - Reconcile completed task with attribution
- `/backlog:task-hold <id> <reason>` - Move task to blocked

Proactive skills (triggered automatically):
- `backlog-update` - Reminds to update backlog and changelog before commits
- `backlog-resume` - Surfaces WIP tasks and handoff notes on session start
- `new-design-doc` - Suggests creating design docs during architecture discussions

## The Workflow

### Document Status Lifecycle

```
Draft → Review → Accepted → Active → Complete
  │        │         │         │
  │        │         │         └── /task-complete (when last task done)
  │        │         └── /queue-design-doc or /task-queue
  │        └── /design-review (resolve questions, finalize tasks)
  └── /new-design-doc
```

| Status   | Meaning                              |
|----------|--------------------------------------|
| Draft    | Under development, not ready         |
| Review   | Ready for feedback                   |
| Accepted | Approved, ready to implement         |
| Active   | Implementation in progress           |
| Complete | Fully implemented and verified       |
| Archived | No longer active (rejected/obsolete) |

### Task Lifecycle

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

### Quick Start (Recommended)

With the Claude Code plugin installed:

```bash
# In your project directory
/backlog:setup
```

The setup skill will:
1. Ask for your project prefix (e.g., `ACME`)
2. Create the directory structure
3. Write template files with your prefix
4. Explain what was created

### Legacy: Bootstrap Script

> **Deprecated**: Use the plugin instead. This script will be removed in a future release.

```bash
git clone https://github.com/farra/dev-agent-backlog.git
./dev-agent-backlog/bin/init.sh MYPREFIX ~/path/to/your-project
```

### Customize org-setup.org

Edit the tags for your project:

```org
#+TAGS: p0 p1 p2 | frontend backend infra
```

### Create Your First Design Doc

Use the slash command:
```
/backlog:new-design-doc Your Feature Name
```

Or manually:
```bash
cp docs/design/000-template.org docs/design/001-first-feature.org
```

### Start Using the Workflow

With Claude Code:
```
/backlog:task-queue PROJECT-001-01
/backlog:task-start PROJECT-001-01
# ... do the work ...
/backlog:task-complete PROJECT-001-01 v1.0
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

Install the plugin once, use in any project:

```bash
/plugin marketplace add farra/dev-agent-backlog
/plugin install backlog@dev-agent-backlog
```

### Slash Commands

| Command | Description |
|---------|-------------|
| `/backlog:setup` | Initialize design doc system in current project |
| `/backlog:new-design-doc <title>` | Create a new design document from template |
| `/backlog:design-review <doc>` | Review doc: resolve questions, finalize tasks |
| `/backlog:queue-design-doc <doc>` | Queue all tasks from a design doc |
| `/backlog:task-queue <id>` | Check out a task to backlog Active section |
| `/backlog:task-start <id>` | Begin work with context and handoff notes |
| `/backlog:task-complete <id> [version]` | Mark done with attribution |
| `/backlog:task-hold <id> <reason>` | Move task to Blocked section |

### Skills (Auto-triggered)

| Skill | Trigger | Behavior |
|-------|---------|----------|
| `backlog-resume` | Session start | Checks for WIP tasks, surfaces handoff notes |
| `backlog-update` | Before commits | Reminds to update backlog, changelog, and handoff notes |
| `new-design-doc` | Architecture discussions | Suggests creating design docs |
| `setup` | "Set up design docs" | Interactive project initialization |

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

Documents are numbered sequentially (001, 002, 003...). Use `#+CATEGORY:` in
the document header to classify documents. Valid categories are defined in
`README.org`:

| Category | Description |
|----------|-------------|
| feature  | Core product functionality |
| infra    | Infrastructure, tooling, CI/CD |
| research | Research, analysis, spikes |
| hygiene  | Tech debt, chores, maintenance |
| incident | Bugs, outages, RCAs |
| security | Audits, vulnerabilities, hardening |
| data     | Storage, pipelines, metrics |
| bs       | Brainstorms, speculative ideas |

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
