# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

dev-agent-backlog is a task management system for human-agent collaboration. It uses org-mode design documents as the source of truth, with a backlog.org file as an ephemeral working surface. This is a template/scaffolding system, not a compiled application.

## Commands

**Bootstrap a new project:**
```bash
./bin/init.sh [PROJECT-PREFIX] [target-dir]
# Example: ./bin/init.sh ACME ~/dev/acme-api
```

There are no build, test, or lint commands - this is a documentation/workflow template.

## Architecture

### Core Pattern: Design Doc → Backlog → Reconcile

```
Design Doc (canonical)          Backlog (working surface)
** TODO [ID] Task              *** TODO [ID] Task
                    ─checkout→  :SOURCE: [[file:...]]
                                progress notes...
** DONE [ID] Task              ←reconcile─ (removed)
```

1. Tasks originate in design docs (`docs/design/*.org`)
2. Active tasks are "checked out" to `backlog.org` with `:SOURCE:` links
3. Progress notes accumulate in backlog during work
4. Completed tasks are reconciled back to design docs

### Key Files

- `backlog.org` - Working surface with Active/Blocked/Up Next sections
- `docs/design/*.org` - RFC/RFD-style design documents (source of truth)
- `org-setup.org` - Shared org-mode config (TODO states, tags, effort levels)
- `CHANGELOG.md` - User-facing change log (keepachangelog format)
- `.claude/commands/` - Slash commands for task workflow
- `.claude/skills/` - Proactive behaviors (backlog-update, backlog-resume, new-design-doc)

### Task ID Format

```
[PROJECT-NNN-XX]
   │      │   └── Task sequence (01, 02, ...)
   │      └────── Design doc number
   └───────────── Project prefix
```

### Document Numbering

- 001-099: Core system
- 100-199: Features
- 200-299: Infrastructure
- 300-399: Tooling
- 800-899: Analysis/Research
- 900-999: Proposals/Future

## Slash Commands

- `/task-queue <id>` - Check out task from design doc to backlog Active section
- `/task-start <id>` - Begin work: gather context, display handoff notes, update attribution
- `/task-complete <id> [version]` - Mark done with attribution, prompt for changelog entry
- `/task-hold <id> <reason>` - Move task to Blocked section
- `/new-design-doc <title> [source.md]` - Create new design doc (or convert markdown)
- `/queue-design-doc <doc>` - Queue all tasks from a design doc with pre-flight checks

## Skills

- `backlog-resume` - Triggers on session start; checks for WIP tasks and surfaces handoff notes
- `backlog-update` - Triggers before commits; reminds to update backlog.org, changelog, and handoff notes
- `new-design-doc` - Triggers during architectural discussions; suggests creating design docs

## Task Properties

### Backlog Entry Properties
- `:SOURCE:` - Link to canonical location in design doc
- `:EFFORT:` - Estimated effort (S, M, L or time)
- `:HANDOFF:` - Notes for next session (what to try, where stuck)
- `:WORKED_BY:` - Who has worked on this (claude-code, human)

### Completed Task Properties (in design doc)
- `:COMPLETED_BY:` - Who marked it done (claude-code | human)
- `:WORKED_BY:` - All contributors
- `:TRANSCRIPT:` - Link to Claude conversation transcript
- `:VERSION:` - Release version (if applicable)

## Org-Mode Conventions

**TODO states:** `TODO → WIP → HOLD | DONE`
**Questions:** `OPEN → DECIDED`
**Effort levels:** 0:15, 0:30, 1:00, 2:00, 4:00, 8:00, 16:00
**Priority tags:** p0, p1, p2
**Category tags:** core, docs, infra (customize per project)

## Working with This Repository

When modifying this template system:
- Design docs in `docs/design/` document the system using itself
- Changes to commands/skills must update both source files and templates
- The `PROJECT` placeholder in templates gets substituted by init.sh
