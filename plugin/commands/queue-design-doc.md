---
description: Queue all tasks from a design doc into backlog.org Active section
argument-hint: <doc-number-or-filename>
---

# Queue Design Doc

Queue all tasks from design document **$ARGUMENTS** into backlog.org Active section.

## Process

### 1. Resolve Document

Find the design document from the identifier:

- If number (e.g., `007`, `7`): Look for `docs/design/007-*.org`
- If filename (e.g., `007-queue-design-doc.org`): Use directly
- If path: Use as provided

Read the document and extract title from `#+TITLE:`.

### 2. Pre-flight Checks

Before queuing tasks, validate the document is ready:

#### 2a. Status Check

Read `#+STATUS:` header:

| Status   | Action |
|----------|--------|
| Accepted | Proceed, will set to Active |
| Active   | Proceed with note "already in progress" |
| Draft    | Warn: "Document is still Draft. Queue anyway?" |
| Review   | Warn: "Document is in Review. Queue anyway?" |
| Complete | Abort: "Document already Complete, no tasks to queue" |
| Archived | Abort: "Document was Archived" |

#### 2b. Open Questions Check

Scan `* Questions` section for `** OPEN` headings.

If any found:
1. List each open question with its body text
2. For each question, help the user decide:
   - Show any options mentioned in the question body
   - Ask for their decision
   - Update the heading to `** DECIDED` with `:DECIDED: [YYYY-MM-DD]` property
   - Add decision rationale
3. After all resolved, continue

#### 2c. Decision Commentary Check

Scan `* Decision` and `* Design` sections for:
- Sub-headings: `*** Comment`, `*** Note`, `*** TODO`, `*** FIXME`
- Inline markers: `TODO:`, `FIXME:`, `NOTE:`, `XXX:`

If found:
1. Surface each comment/note with context
2. Ask: "Address this before proceeding? (yes/no/skip all)"
3. If yes: help resolve and update document
4. If no/skip: continue

### 3. Task Discovery

Find `* Tasks` section and collect all `** TODO` headings:

- Extract task ID from heading (pattern: `[PROJECT-NNN-XX]`)
- Extract title (rest of heading after ID)
- Read `:EFFORT:` property
- Read body text as description

Skip headings with states: `DONE`, `HOLD`, `WIP`

### 4. Backlog Integration

Read `backlog.org` and for each discovered task:

#### New Tasks (ID not in backlog)

Add to `** Active` section:

```org
*** TODO [TASK-ID] Task Title                                            :tags:
:PROPERTIES:
:SOURCE: [[file:docs/design/NNN-doc.org::*Tasks][TASK-ID in NNN-doc.org]]
:EFFORT: <from source>
:HANDOFF:
:WORKED_BY:
:END:

<description from source>
```

#### Existing Tasks (ID found in backlog)

- Move to `** Active` if currently in Blocked or Up Next
- Update `:EFFORT:` if changed in source
- Preserve existing `:HANDOFF:` and `:WORKED_BY:`
- Preserve existing progress notes

### 5. Update Document Status

After queuing tasks:
- If `#+STATUS:` was `Accepted` (or `Draft`/`Review` and user confirmed), set to `Active`
- Update `docs/design/README.org` index to reflect new status
- Work has begun on this design doc

### 6. Summary Output

Display results:

```
## Queued: NNN - Document Title

**Pre-flight:**
- Status: Accepted ✓
- Questions: 2 DECIDED, 0 OPEN ✓
- Comments: None found ✓

**Tasks queued to Active:**
- [DAB-007-01] Task title (NEW)
- [DAB-007-02] Another task (UPDATED - was in Blocked)

**Skipped:**
- [DAB-007-03] Completed task (DONE)
```

## Examples

```
/queue-design-doc 007
/queue-design-doc 7
/queue-design-doc 007-queue-design-doc
/queue-design-doc docs/design/007-queue-design-doc.org
```

## Files

- Design docs: `docs/design/*.org`
- Backlog: @backlog.org (Current WIP > Active section)
