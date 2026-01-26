---
description: Start or resume work on a task from the backlog. Reviews context and prepares an implementation plan.
argument-hint: <task-id>
---

# Start Task

Start or resume work on task **$ARGUMENTS**.

## Process

### 1. Check if Task is in Backlog

Look for the task in backlog.org under `* Current WIP` > `** Active`.

- If found: proceed to step 2
- If NOT found: run `/task-queue $ARGUMENTS` first to add it

### 2. Read Task Context and Handoff

From the task entry in backlog.org:
- Read any existing progress notes
- Check `:HANDOFF:` property for notes from previous session
- Follow the `:DESIGN:` link to the design doc (if present)
- Read the full task description and related context

**If `:HANDOFF:` has content, display prominently:**

```
## Resuming [$ARGUMENTS]

**Handoff from last session:**
> <handoff notes here>
```

### 2a. Update Attribution

- Change task state from TODO to WIP
- Add `claude-code` to `:WORKED_BY:` if not already present

### 3. Gather Related Context

Read the full design doc containing the task:
- Motivation section (why this matters)
- Design section (how it should work)
- Related tasks (dependencies, sequence)
- Open questions (blockers, decisions needed)

### 4. Prepare Implementation Plan

Create a plan with:
- **Goal**: What we're trying to achieve
- **Approach**: How we'll implement it
- **Files to modify**: List of files we'll touch
- **Steps**: Ordered implementation steps
- **Open questions**: Anything that needs clarification

### 5. Present Plan for Review

Present the plan to the user for approval before beginning implementation.

## Example

```
/task-start DAB-001-01
```

## Files

- Backlog: `backlog.org` (Current WIP > Active)
- Design docs: `docs/design/*.org`
