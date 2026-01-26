---
description: Move a task to HOLD/Blocked status with a reason
argument-hint: <task-id> <reason>
---

# Task Hold

Move task **$1** to blocked/hold status with reason: **$2**

## Process

1. **Find task in backlog.org** under `* Current WIP` > `** Active`:
   - Look for `*** TODO [$1]` entry

2. **Move to Blocked section**:
   - Cut the task from `** Active`
   - Paste under `** Blocked`
   - Add `:REASON:` property with the provided reason

3. **Confirm** the move

## Example

```
/task-hold DAB-001-01 Waiting for dependency release
```

## Format in backlog.org

Before (in Active):
```org
*** TODO [DAB-001-01] Task title
:PROPERTIES:
:DESIGN: [[file:...][...]]
:EFFORT: M
:END:
```

After (in Blocked):
```org
*** TODO [DAB-001-01] Task title
:PROPERTIES:
:DESIGN: [[file:...][...]]
:EFFORT: M
:REASON: Waiting for dependency release
:END:
```

## Files

- Backlog: @backlog.org (Current WIP section)
