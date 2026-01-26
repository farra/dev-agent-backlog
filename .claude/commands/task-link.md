---
description: Add link properties to an existing backlog task
argument-hint: <task-id> --github <url> | --claude-task <id> | --bead <ref> | --design <path>
---

# Task Link

Add link properties to backlog task **$ARGUMENTS**.

## Purpose

The backlog is a hub linking to tasks wherever they live. This command adds those links to existing tasks—connecting a backlog entry to its representations in other systems.

## Usage

```
/task-link <task-id> --github <url>
/task-link <task-id> --claude-task <task-list-id>/<task-id>
/task-link <task-id> --bead <session>/<task>
/task-link <task-id> --design <path-to-design-doc>::*<heading>
```

Multiple links can be added at once:

```
/task-link DAB-012-02 --github https://github.com/org/repo/issues/15 --claude-task abc123/task-001
```

## Process

### 1. Find Task in Backlog

Search `backlog.org` for the task ID in:
- `* Current WIP` > `** Active`
- `* Current WIP` > `** Blocked`
- `* Up Next`

If not found, report error and suggest `/task-queue` to add it first.

### 2. Parse Link Arguments

Extract link type and value from arguments:

| Flag | Property | Example Value |
|------|----------|---------------|
| `--github` | `:GITHUB:` | `https://github.com/org/repo/issues/15` |
| `--claude-task` | `:CLAUDE_TASK:` | `abc123/task-001` |
| `--bead` | `:BEAD:` | `session-xyz/task-002` |
| `--design` | `:DESIGN:` | `docs/design/012-doc.org::*Tasks` |

### 3. Format Link Properties

Convert to org-mode link format:

**GitHub:**
```org
:GITHUB: [[https://github.com/org/repo/issues/15][#15]]
```

**Claude Task:**
```org
:CLAUDE_TASK: abc123/task-001
```

**Bead:**
```org
:BEAD: [[bead:session-xyz/task-002][bead ref]]
```

**Design:**
```org
:DESIGN: [[file:docs/design/012-doc.org::*Tasks][DAB-012-02 in 012-doc.org]]
```

### 4. Update Task Properties

Add the new properties to the task's `:PROPERTIES:` drawer.

- If property already exists, ask before overwriting
- Preserve all existing properties
- Add new properties in standard order: DESIGN, CLAUDE_TASK, GITHUB, BEAD, then metadata

### 5. Confirm Changes

Display the updated task:

```
## Linked: [DAB-012-02] Task Title

Added:
- :GITHUB: [[https://github.com/org/repo/issues/15][#15]]

Properties now:
- :DESIGN: [[file:...][...]]
- :CLAUDE_TASK: abc123/task-001
- :GITHUB: [[https://github.com/org/repo/issues/15][#15]]
- :EFFORT: M
```

## Examples

```
# Link to GitHub issue
/task-link DAB-012-02 --github https://github.com/farra/dev-agent-backlog/issues/15

# Link to Claude Task
/task-link DAB-012-02 --claude-task dab-012/task-002

# Link to design doc (if task was added directly to backlog)
/task-link FIX-001 --design docs/design/015-bugfix.org::*Tasks

# Multiple links at once
/task-link DAB-012-02 --github https://github.com/org/repo/issues/15 --bead session-abc/task-002
```

## Use Cases

1. **Task originated in GitHub**: Issue created in GitHub, now tracking in backlog
2. **Retroactive design doc**: Quick fix now being formalized in a design doc
3. **Cross-session work**: Adding Claude Task link for coordination
4. **Multiple systems**: Same task tracked in GitHub AND design doc

## Files

- Backlog: `backlog.org`
