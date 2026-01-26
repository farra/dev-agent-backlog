# Backlog Plugin for Claude Code

Design doc driven task management for human-agent collaboration.

For full documentation, see the [GitHub repository](https://github.com/farra/dev-agent-backlog).

## Quick Start

```bash
# Set up your project (interactive)
/backlog:setup

# Or just say: "Set up design docs for this project"
```

## Commands

| Command                            | Description                               |
|------------------------------------|-------------------------------------------|
| `/backlog:setup`                   | Initialize design doc system in a project |
| `/backlog:new-design-doc <title>`  | Create a new design document              |
| `/backlog:design-review <doc>`     | Guide doc through review workflow         |
| `/backlog:queue-design-doc <doc>`  | Queue all tasks from a design doc         |
| `/backlog:task-queue <id>`         | Queue a task from design doc to backlog   |
| `/backlog:task-start <id>`         | Begin work on a task                      |
| `/backlog:task-complete <id>`      | Mark a task as done                       |
| `/backlog:task-hold <id> <reason>` | Move task to blocked                      |
| `/backlog:task-link <id> <flags>`  | Add link properties to a task             |

## Skills (Auto-triggered)

| Skill            | Triggers when...                                 |
|------------------|--------------------------------------------------|
| `backlog-resume` | Session starts with WIP tasks                    |
| `backlog-update` | Before commits, reminds to update backlog        |
| `new-design-doc` | Architectural discussions suggest creating a doc |
| `setup`          | User wants to initialize design doc system       |

## Task ID Format

```
[PREFIX-NNN-XX]
   │      │   └── Task sequence (01, 02, ...)
   │      └────── Design doc number
   └───────────── Project prefix (e.g., ACME)
```

## Learn More

- [Full Documentation](https://github.com/farra/dev-agent-backlog)
- [Design Doc Pattern](https://github.com/farra/dev-agent-backlog/blob/main/docs/design/002-design-docs.org)
- [Backlog Workflow](https://github.com/farra/dev-agent-backlog/blob/main/docs/design/003-backlog-workflow.org)
