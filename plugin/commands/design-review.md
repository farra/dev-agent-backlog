---
description: Review a design doc - resolve questions, finalize tasks, move to Accepted
argument-hint: <doc-number-or-filename>
---

# Design Review

Guide design document **$ARGUMENTS** through the review process: Draft → Review → Accepted.

## Process

### 1. Resolve Document

Find the design document from the identifier:

- If number (e.g., `010`, `10`): Look for `docs/design/010-*.org`
- If filename (e.g., `010-design-doc-metadata.org`): Use directly
- If path: Use as provided

Read the document and extract:
- `#+TITLE:` for display
- `#+STATUS:` for current state
- `#+CATEGORY:` for context

### 2. Set Review Status

If `#+STATUS:` is `Draft`:
- Change to `Review`
- Update `docs/design/README.org` index
- Announce: "Document is now in Review status"

If already `Review` or `Accepted`:
- Continue with the review process

If `Active`, `Complete`, or `Archived`:
- Abort: "Document is already past the review stage"

### 3. Review Open Questions

Scan `* Questions` section for `** OPEN` headings.

For each open question:
1. Display the question and any context/options in its body
2. Discuss with the user to reach a decision
3. When decided:
   - Change `** OPEN` to `** DECIDED`
   - Add `:DECIDED: [YYYY-MM-DD]` property
   - Add decision rationale to the body
4. Continue to next question

If no open questions, proceed to step 4.

### 4. Review Design Sections

Scan `* Design` and `* Decision` sections for unresolved items:

- Sub-headings: `*** TODO`, `*** FIXME`, `*** Comment`, `*** Note`
- Inline markers: `TODO:`, `FIXME:`, `XXX:`

For each item found:
1. Surface the item with surrounding context
2. Ask: "How should we resolve this?"
3. Update or remove the marker based on resolution

### 5. Review Tasks

Scan `* Tasks` section for `** TODO` headings.

Present a summary:
- List all tasks with their IDs, titles, and effort estimates
- Identify any tasks that seem underspecified
- Ask: "Are these tasks complete and ready for implementation?"

If tasks need refinement:
- Help the user add, modify, or remove tasks
- Ensure each task has an ID, clear title, and effort estimate

### 6. Final Confirmation

When all questions are decided and tasks are finalized:

Ask: "All questions are resolved and tasks are ready. Mark as Accepted?"

If yes:
- Change `#+STATUS:` to `Accepted`
- Update `docs/design/README.org` index
- Announce: "Document is now Accepted and ready for implementation"

If no:
- Leave as `Review` for further refinement
- Summarize what was accomplished

### 7. Offer to Queue

If document was marked Accepted:
- Ask: "Would you like to queue the tasks to backlog.org now?"
- If yes: run `/queue-design-doc` logic

## Status Transitions

```
Draft → Review → Accepted
  │       │         │
  │       │         └── Ready for implementation
  │       └── Questions being resolved, tasks being finalized
  └── Initial creation, not ready for review
```

## Example

```
/design-review 010
/design-review 010-design-doc-metadata
```

Reviews design doc 010, resolves open questions, finalizes tasks, and moves to Accepted.

## Files

- Design docs: `docs/design/*.org`
- Index: `docs/design/README.org`
