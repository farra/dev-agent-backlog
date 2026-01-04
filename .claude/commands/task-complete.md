---
description: Mark a task complete - update source doc and remove from backlog.org
argument-hint: <task-id> [version]
---

# Task Complete

Mark task **$1** as DONE and reconcile with source document.

## Process

1. **Find task in backlog.org** under `* Current WIP` > `** Active`:
   - Look for `*** TODO [$1]` or `*** WIP [$1]` entry
   - Get `:SOURCE:` link to find canonical location
   - Note `:WORKED_BY:` value for attribution

2. **Gather attribution**:
   - Ask: "Who completed this task? (claude-code / human)"
   - Look for current transcript in `~/.claude/projects/` directory

3. **Update source document**:
   - Change `** TODO` to `** DONE`
   - Add `CLOSED: [YYYY-MM-DD]` timestamp
   - If version provided ($2), add `:VERSION:` property
   - Add `:COMPLETED_BY:` from step 2
   - Add `:WORKED_BY:` from backlog entry
   - Add `:TRANSCRIPT:` link if transcript found

4. **Remove from backlog.org**:
   - Delete the task entry from Active section

5. **Prompt for CHANGELOG.md**:
   - Ask: "Add to CHANGELOG.md? (Added/Changed/Fixed/Removed/Skip)"
   - If not Skip, add entry under `## [Unreleased]` in appropriate section

6. **Confirm** the reconciliation

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
:EFFORT: M
:VERSION: v1.0
:COMPLETED_BY: claude-code
:WORKED_BY: claude-code, human
:TRANSCRIPT: [[file:~/.claude/projects/.../conversation.md]]
:END:
```

## Files

- Backlog: @backlog.org (Current WIP section)
- Follow `:SOURCE:` link to find canonical location
