---
name: backlog-resume
description: Check for in-progress work on session start. Use when beginning a new session in a project with backlog.org. Triggers automatically at session start or when user says "what was I working on?", "resume", "continue", or "where did I leave off?". Surfaces WIP tasks and handoff notes to enable seamless session continuity.
---

# Backlog Resume

This skill checks for in-progress work when starting a new session, implementing the "hook pattern" from gastown - if there's work on your hook, you should run it.

## Prerequisites

**Before triggering, check that `backlog.org` exists in the project root.**

If `backlog.org` does not exist, do NOT trigger this skill. The project hasn't been
set up with the backlog system yet. Silently skip - don't suggest setup or explain
why the skill isn't running.

## When to Offer This Workflow

**Trigger conditions:**
- `backlog.org` exists in the project root, AND
- Starting a new session in a project with `backlog.org`
- User asks "what was I working on?", "resume", "continue"
- User says "where did I leave off?"

**Initial check:**
Read `backlog.org` and look for WIP tasks in the Active section.

## Workflow

### 1. Check for WIP Tasks

Read `* Current WIP` > `** Active` section in backlog.org.

Look for tasks with state `WIP` (work in progress).

### 2. Surface Handoff Notes and Claude Task State

For each WIP task found:
- Read the `:HANDOFF:` property
- Read recent progress notes (entries starting with `[YYYY-MM-DD]`)
- Check for `:CLAUDE_TASK:` property

**If `:CLAUDE_TASK:` exists:**
- Note the Task List ID for cross-session coordination
- Check if there are related Tasks or dependencies
- This task has agent coordination enabled

### 3. Present Resume Option

If WIP task(s) found, display:

```
## Work in Progress

Found active work from previous session:

### [TASK-ID] Task Title

**Handoff notes:**
> <content of :HANDOFF: property>

**Recent progress:**
> <last progress note>

**Claude Task:** <task-list-id>/<task-id> (if present)

Continue working on this task?
```

The Claude Task link (if present) enables cross-session coordination.
Follow the link to check for any updates from subagents or other sessions.

### 4. Quick Consistency Check

While reviewing backlog.org, perform a lightweight consistency check:

**Stale entries:**
- If any tasks show `*** DONE` in backlog.org, they should have been removed
- Suggest: "Found completed task [ID] still in backlog. Remove it?"

**Design doc drift:**
- For WIP/TODO tasks with `:DESIGN:` links, spot-check the source doc
- If the source doc shows the task as `** DONE` but backlog shows TODO/WIP:
  - Suggest removing the stale backlog entry
- If the design doc `#+STATUS:` is Complete but tasks are still in backlog:
  - Suggest running `/reconcile-backlog` to clean up

This catches drift early without running a full reconciliation.

### 5. If No WIP Tasks

Check if there are TODO tasks in Active section:

```
## Ready to Start

No work in progress. Active queue:

1. [TASK-ID-1] Task title
2. [TASK-ID-2] Task title

Start one of these tasks?
```

### 6. Handle Response

- If user wants to continue: Run `/task-start <task-id>`
- If user wants different task: Queue or start the requested task
- If user declines: Proceed with whatever they want to do

## Example

```
User: <starts session>

Claude: "Checking backlog.org for in-progress work...

## Work in Progress

Found active work from previous session:

### [DAB-005-01] Implement handoff notes

**Handoff notes:**
> Stuck on property format. Check org-mode docs for multi-line properties.

**Recent progress:**
> [2026-01-03] Started implementation. Template updated.

Continue working on this task?"
```

## Related Commands

| Command | When to use |
|---------|-------------|
| `/task-start <id>` | Resume the WIP task |
| `/task-queue <id>` | Add a new task to Active |
| `/task-hold <id> <reason>` | If task is blocked |
