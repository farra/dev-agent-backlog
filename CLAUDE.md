# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

dev-agent-backlog is a task management system for human-agent collaboration, built on two core ideas:

1. **backlog.org as universal hub** - A human-readable join table linking to tasks wherever they live (design docs, Claude Tasks, GitHub issues, etc.). Both humans and agents read the backlog; agents follow links to their native primitives.

2. **Design docs for agent planning** - RFC/RFD-style org-mode documents where agents think through problems before executing. Design docs capture context, decisions, and tasks—then feed execution via `/queue-design-doc`.

This is a template/scaffolding system, not a compiled application.

## Commands

**Bootstrap a new project:**
```bash
./bin/init.sh [PROJECT-PREFIX] [target-dir]
# Example: ./bin/init.sh ACME ~/dev/acme-api
```

There are no build, test, or lint commands - this is a documentation/workflow template.

## Architecture

### Core Pattern: Backlog as Hub

```
                        backlog.org (hub/glue)
                              │
         ┌────────────┬───────┴───────┬────────────┐
         ▼            ▼               ▼            ▼
    Design Doc    Claude Task    GitHub Issue    Bead
    :DESIGN:      :CLAUDE_TASK:  :GITHUB:        :BEAD:
```

backlog.org is a human-readable hub linking to tasks wherever they live:
1. Tasks can originate in design docs, GitHub issues, or Claude Tasks
2. Active tasks are tracked in `backlog.org` with link properties
3. Progress notes and `:HANDOFF:` accumulate in backlog during work
4. Completed tasks are reconciled back to their source (if applicable)

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

Documents are numbered sequentially (001, 002, ...). Use `#+CATEGORY:` in the
document frontmatter to classify documents. Valid categories are defined in
`README.org`:

- `feature` - Core product functionality
- `infra` - Infrastructure, tooling, CI/CD
- `research` - Research, analysis, spikes
- `hygiene` - Tech debt, chores, maintenance
- `incident` - Bugs, outages, RCAs
- `security` - Audits, vulnerabilities, hardening
- `data` - Storage, pipelines, metrics
- `bs` - Brainstorms, speculative ideas

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
- `claude-tasks-sync` - Triggers when using Claude Tasks; ensures cross-references exist in backlog.org
- `new-design-doc` - Triggers during architectural discussions; suggests creating design docs

## Task Properties

### Backlog Entry Link Properties (all optional)
- `:DESIGN:` - Link to canonical location in design doc
- `:CLAUDE_TASK:` - Link to Claude Task for cross-session coordination
- `:GITHUB:` - Link to GitHub issue
- `:BEAD:` - Link to Bead reference

### Backlog Entry Metadata Properties
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
