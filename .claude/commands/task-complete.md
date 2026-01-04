---
description: Mark a task complete - update source doc and remove from backlog.org
argument-hint: <task-id> [version]
---

# Task Complete

Mark task **$1** as DONE and reconcile with source document.

## Process

1. **Find task in backlog.org** under `* Current WIP` > `** Active`:
   - Look for `*** TODO [$1]` entry
   - Get `:SOURCE:` link to find canonical location

2. **Update source document**:
   - Change `** TODO` to `** DONE`
   - Add `CLOSED: [YYYY-MM-DD]` timestamp
   - If version provided ($2), add `:VERSION:` property

3. **Remove from backlog.org**:
   - Delete the `*** TODO` entry from Active section

4. **Confirm** the reconciliation

## Example

```
/task-complete DAB-001-01 v1.0
```

Marks DAB-001-01 as DONE with version v1.0.

## Format in Source Doc

Before:
```org
** TODO [DAB-001-01] Task title
:PROPERTIES:
:EFFORT: M
:END:
```

After:
```org
** DONE [DAB-001-01] Task title
CLOSED: [2026-01-04]
:PROPERTIES:
:VERSION: v1.0
:EFFORT: M
:END:
```

## Files

- Backlog: @backlog.org (Current WIP section)
- Follow `:SOURCE:` link to find canonical location
