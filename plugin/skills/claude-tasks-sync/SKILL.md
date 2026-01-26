---
name: claude-tasks-sync
description: Ensures Claude Tasks are cross-referenced in backlog.org. Triggers when creating Claude Tasks, using TodoWrite, or when subagents create tasks. This keeps backlog.org as the human-readable hub while agents use their native primitives. Trigger when using task management features, spawning subagents, or completing multi-step work.
---

# Claude Tasks Sync

This skill ensures Claude Tasks are cross-referenced in backlog.org. The backlog is the universal hub - humans read it directly, agents follow links to their native primitives.

## Core Principle

**Sync means cross-references, not content replication.**

- When Claude creates a Task, ensure backlog.org has an entry with `:CLAUDE_TASK:` link
- Don't duplicate task descriptions - just ensure the link exists
- Humans read backlog.org; agents follow links to Claude Tasks

## When to Trigger

**Trigger conditions:**
- Creating Claude Tasks (via TodoWrite or task management)
- Spawning subagents that will create their own Tasks
- After `/queue-design-doc` creates a Task List
- When completing work that involved Claude Tasks

## Workflow

### 1. When Creating Claude Tasks

After creating one or more Claude Tasks:

1. Read backlog.org's `* Current WIP` > `** Active` section
2. For each Claude Task created:
   - Check if a matching backlog entry exists (by task ID or title)
   - If exists: add `:CLAUDE_TASK:` property if missing
   - If not exists: create minimal backlog entry with link

**Minimal backlog entry:**

```org
*** TODO Task title
:PROPERTIES:
:CLAUDE_TASK: <task-list-id>/<task-id>
:EFFORT: M
:HANDOFF:
:WORKED_BY: claude-code
:END:
```

### 2. When Tasks Have Design Doc Origin

If the task originated from a design doc (has `:DESIGN:` property), preserve it:

```org
*** TODO [DAB-012-08] Create sync skill
:PROPERTIES:
:DESIGN: [[file:docs/design/012-claude-tasks-integration.org::*Tasks][DAB-012-08]]
:CLAUDE_TASK: <task-list-id>/<task-id>
:EFFORT: M
:END:
```

Both links coexist - `:DESIGN:` for the spec, `:CLAUDE_TASK:` for agent coordination.

### 3. When Subagents Create Tasks

If spawning subagents:

1. Note the Task List ID being used
2. After subagent completes, check for any new Tasks created
3. Ensure each new Task has a corresponding backlog entry

### 4. Link Format

The `:CLAUDE_TASK:` property format:

```org
:CLAUDE_TASK: <task-list-id>/<task-id>
```

Or for referencing just the Task List:

```org
:CLAUDE_TASK_LIST: <task-list-id>
```

## What NOT To Do

- Don't copy task descriptions from Claude Tasks to backlog
- Don't mirror status changes automatically
- Don't create duplicate entries - one per task
- Don't remove `:DESIGN:` or other existing links

## Example

```
Claude: [Creates Task "Implement authentication" via TodoWrite]

[Skill triggers]

Claude: "I've created a Claude Task for this work. Let me ensure
it's tracked in backlog.org...

Added to backlog.org Active section:
*** TODO Implement authentication
:PROPERTIES:
:CLAUDE_TASK: abc123/task-001
:EFFORT: M
:WORKED_BY: claude-code
:END:

The task is now visible to both humans (via backlog) and agents
(via Claude Task)."
```

## Related Skills

| Skill | Relationship |
|-------|--------------|
| `backlog-update` | Updates existing entries; this creates new ones |
| `backlog-resume` | Reads `:CLAUDE_TASK:` links on session start |

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/task-start` | Creates Claude Task at execution time |
| `/queue-design-doc` | Creates Task List for all design doc tasks |
