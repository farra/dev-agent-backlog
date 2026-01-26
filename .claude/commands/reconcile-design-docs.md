---
description: Reconcile design doc task statuses with git log, changelog, and source code evidence
argument-hint: [doc-pattern]
---

# Reconcile Design Docs

Scan design documents and cross-reference task statuses with evidence from git log, CHANGELOG.md, and source code. Automatically fix clear-cut cases and interactively review ambiguous ones.

## Arguments

- **doc-pattern** (optional): Glob pattern to filter docs (e.g., `007*`, `*workflow*`). Defaults to all numbered docs.

## Process

1. **Enumerate design docs**:
   - Find all `docs/design/[0-9]*.org` files
   - If pattern provided ($1), filter to matching docs
   - Skip docs with `#+STATUS: Complete` or `#+STATUS: Archived`

2. **For each design doc** (use subagents if >3 docs):
   - Parse document header for `#+STATUS:` and `#+TITLE:`
   - Find all task headings: `** TODO`, `** WIP`, `** HOLD`
   - Extract task IDs matching pattern `[PROJECT-NNN-XX]`

3. **Gather evidence for each incomplete task**:
   - **Git log**: Search for task ID in commit messages
     ```bash
     git log --oneline --all --grep="TASK-ID"
     ```
   - **CHANGELOG.md**: Search for task ID or related keywords
   - **Source code**: Check if described functionality exists
     - For command tasks: check `.claude/commands/`
     - For feature tasks: search for implementation patterns

4. **Classify each task**:
   - `confirmed-todo`: No evidence of completion
   - `likely-done`: Strong evidence (git commit with ID, changelog entry)
   - `unclear`: Partial evidence (related commits but no direct mention)

5. **Present findings and auto-fix options**:
   ```
   ## Design Doc: 007-queue-design-doc.org (Active)

   ### Likely Complete (will mark DONE):
   - [DAB-007-01] Create command file
     Evidence: git:abc123 "Add queue-design-doc command"

   ### Unclear (needs review):
   - [DAB-007-03] Add pre-flight checks
     Evidence: changelog mentions "pre-flight" but no task ID

   ### Confirmed TODO (no changes):
   - [DAB-007-04] Support batch mode

   Apply auto-fixes? [y/n]:
   ```

6. **Apply changes**:
   - For `likely-done` tasks (if confirmed):
     - Change `** TODO` to `** DONE`
     - Add `CLOSED: [YYYY-MM-DD]` timestamp (today's date)
     - Add `:RECONCILED:` property with evidence source
     - Add `:COMPLETED_BY: reconciliation` to indicate auto-detected

7. **Interactive review for unclear items**:
   - Present evidence for each unclear task
   - Ask: "Mark as DONE? [y/n/skip]"
   - If yes, apply same changes as step 6

8. **Check document status**:
   - After processing tasks, count remaining incomplete tasks
   - If all tasks are DONE or HOLD:
     - Prompt: "All tasks complete. Mark doc as #+STATUS: Complete? [y/n]"
     - If yes, update `#+STATUS:` and `#+LAST_MODIFIED:`

9. **Generate report**:
   ```
   ## Reconciliation Summary

   ### Documents Processed: 8

   ### Auto-Applied Changes:
   - [DAB-003-02] → DONE (git evidence)
   - [DAB-005-01] → DONE (changelog evidence)
   - 003-backlog-workflow.org → Complete

   ### User-Confirmed Changes:
   - [DAB-007-03] → DONE

   ### No Changes Needed:
   - 001-system-overview.org (already Complete)
   - 002-design-docs.org (2 tasks still TODO)

   ### Warnings:
   - 010-design-doc-metadata.org has tasks without IDs (3 untracked)
   ```

## Evidence Confidence Levels

| Evidence Type | Confidence | Auto-apply? |
|--------------|------------|-------------|
| Git commit mentions exact task ID | High | Yes |
| CHANGELOG entry mentions task ID | High | Yes |
| Git commit describes same work | Medium | Review |
| CHANGELOG entry describes same work | Medium | Review |
| Source code exists for feature | Medium | Review |
| File timestamps suggest done | Low | No |

## Strictness Rules

- **Never downgrade**: A DONE task is never changed back to TODO
- **Partial is partial**: If 8/10 tasks are done, doc stays Active
- **Evidence required**: No status changes without at least one evidence source
- **Preserve properties**: Existing `:EFFORT:`, `:VERSION:` etc. are kept

## Task Format After Reconciliation

Before:
```org
** TODO [DAB-003-02] Implement checkout flow
:PROPERTIES:
:EFFORT: M
:END:
```

After:
```org
** DONE [DAB-003-02] Implement checkout flow
CLOSED: [2026-01-26]
:PROPERTIES:
:EFFORT: M
:RECONCILED: git:abc123 "Add task-queue checkout command"
:COMPLETED_BY: reconciliation
:END:
```

## Files

- Design docs: @docs/design/[0-9]*.org
- Evidence sources: git log, @CHANGELOG.md, source code
- Index: @docs/design/README.org (update if doc status changes)

## Example

```
/reconcile-design-docs
```

Reconcile all design docs.

```
/reconcile-design-docs 010*
```

Reconcile only doc 010 and any matching the pattern.

## Related Commands

- `/reconcile-backlog` - Reconcile backlog.org entries
- `/task-complete` - Manually mark a single task complete
- `/queue-design-doc` - Queue tasks for execution
