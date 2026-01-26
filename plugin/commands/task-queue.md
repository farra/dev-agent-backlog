---
description: Queue a task from design docs into backlog.org Active section
argument-hint: <task-id>
---

# Task Queue

Queue task **$ARGUMENTS** into the backlog.org Active section.

## Process

1. **Find the task** in design docs:
   - Look in `docs/design/*.org` for the task ID
   - Task IDs follow pattern `[PROJECT-NNN-XX]`

2. **Extract task info**:
   - Full heading
   - `:EFFORT:` property if present
   - Source file path

3. **Add to backlog.org**:
   - Insert under `* Current WIP` > `** Active` section
   - Use this format:

```org
*** TODO [TASK-ID] Task Title
:PROPERTIES:
:DESIGN: [[file:docs/design/NNN-doc.org::*heading][TASK-ID in doc.org]]
:EFFORT: <from source>
:HANDOFF:
:WORKED_BY:
:END:

<brief description>
```

   - `:HANDOFF:` starts empty (populated during work)
   - `:WORKED_BY:` starts empty (updated by /task-start)

4. **Update source doc status**:
   - Read the source design doc's `#+STATUS:` header
   - If status is `Accepted`, change to `Active` (work has begun)
   - If status is `Draft` or `Review`, leave as-is (task can still be queued)
   - Update `docs/design/README.org` index if status changed

5. **Confirm** by showing the new entry

## Files

- Backlog: @backlog.org (Current WIP > Active section)
- Design docs: `docs/design/*.org`
