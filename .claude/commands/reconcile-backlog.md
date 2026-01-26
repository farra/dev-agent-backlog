---
description: Reconcile backlog.org entries - validate links, remove stale items, sync with sources
argument-hint: [--dry-run]
---

# Reconcile Backlog

Scan backlog.org for stale entries, broken links, and status inconsistencies. Cross-reference with design docs, git log, and CHANGELOG.md to identify completed or orphaned tasks.

## Arguments

- **--dry-run** (optional): Show what would change without making modifications

## Process

1. **Parse backlog.org**:
   - Read `* Current WIP` section
   - Extract all entries from `** Active`, `** Blocked`, `** Up Next`
   - For each entry, capture:
     - Task ID (from heading)
     - Status (TODO, WIP, HOLD)
     - `:DESIGN:` link (if present)
     - `:CLAUDE_TASK:` link (if present)
     - `:GITHUB:` link (if present)
     - `:HANDOFF:` notes
     - `:WORKED_BY:` attribution

2. **Validate each entry**:

   a. **Link validation** (if `:DESIGN:` present):
      - Parse the file path and heading target
      - Verify the linked file exists
      - Verify the heading/task exists in that file
      - Check task status in source doc

   b. **Git evidence**:
      - Search for task ID in commit messages:
        ```bash
        git log --oneline --all --grep="TASK-ID"
        ```
      - Look for completion indicators ("done", "complete", "finish")

   c. **CHANGELOG evidence**:
      - Search CHANGELOG.md for task ID mentions
      - Search for feature descriptions matching task

3. **Classify each entry**:

   | Classification | Criteria | Action |
   |----------------|----------|--------|
   | `valid` | Links work, no completion evidence | Keep |
   | `orphan` | `:DESIGN:` link broken (file/heading missing) | Remove or fix |
   | `stale-source` | Source doc task is DONE | Remove |
   | `stale-evidence` | Git/changelog shows completed | Review → Remove |
   | `inconsistent` | Backlog status ≠ source status | Sync |
   | `no-links` | No `:DESIGN:` or other link properties | Warn |

4. **Present findings**:
   ```
   ## Backlog Reconciliation

   ### Orphan Entries (link broken):
   - [PROJECT-010-03] - File docs/design/010-*.org exists but heading not found
     Options: [r]emove / [f]ix link / [s]kip

   ### Stale Entries (source marked DONE):
   - [DAB-003-02] - Source doc shows DONE, backlog shows TODO
     Will remove from backlog.

   ### Stale Entries (completion evidence):
   - [DAB-007-01] - Git commit abc123: "Complete queue-design-doc command"
     Mark as completed? [y/n/skip]

   ### Inconsistent Status:
   - [DAB-005-04] - Backlog: TODO, Source: WIP
     Sync to source status (WIP)? [y/n]

   ### Valid Entries (no changes):
   - [DAB-011-06] - Active, links valid

   ### Warnings:
   - [DAB-012-05] - No :DESIGN: link (cannot validate against source)
   ```

5. **Apply changes** (unless --dry-run):
   - Remove orphan entries (after confirmation)
   - Remove stale entries (source DONE → auto, evidence → confirm)
   - Sync inconsistent statuses
   - Log all removals to "Recently Completed" section

6. **Handle stale sections**:
   - Check for entire sections that may be stale (e.g., "Superseded by Plugin")
   - If all entries in a section are stale, offer to remove the section
   - Example:
     ```
     Section "Superseded by Plugin (010)" has 10 entries, all stale.
     Remove entire section? [y/n]
     ```

7. **Generate report**:
   ```
   ## Backlog Reconciliation Summary

   ### Entries Removed: 5
   - [DAB-003-02] (source DONE)
   - [DAB-005-01] (git evidence)
   - [PROJECT-010-01] through [PROJECT-010-03] (orphan - doc restructured)

   ### Entries Updated: 2
   - [DAB-005-04] TODO → WIP (synced with source)
   - [DAB-007-03] Fixed :DESIGN: link

   ### Sections Removed: 1
   - "Superseded by Plugin (010)" (all entries stale)

   ### Current State:
   - Active: 3 entries
   - Blocked: 0 entries
   - Up Next: 2 entries

   ### Warnings:
   - 2 entries have no :DESIGN: link (manually verify)
   ```

## Entry Classification Logic

```
Entry
 │
 ├─ Has :DESIGN: link?
 │   ├─ Yes → File exists?
 │   │         ├─ Yes → Heading exists?
 │   │         │         ├─ Yes → Source status?
 │   │         │         │         ├─ DONE → stale-source
 │   │         │         │         ├─ Same as backlog → valid
 │   │         │         │         └─ Different → inconsistent
 │   │         │         └─ No → orphan
 │   │         └─ No → orphan
 │   └─ No → Check git/changelog
 │             ├─ Completion evidence → stale-evidence
 │             └─ No evidence → no-links (warn)
 │
 └─ Check git/changelog anyway (supplemental)
```

## Removal Format

When removing entries, move task ID to "Recently Completed" section:

```org
** Recently Completed (Reconciliation 2026-01-26)

- [DAB-003-02] Implement checkout flow (reconciled: source DONE)
- [DAB-005-01] Add changelog prompt (reconciled: git evidence)
```

## Strictness Rules

- **Never delete without evidence**: Every removal requires a reason
- **Preserve history**: Removed task IDs go to "Recently Completed"
- **Warn on no-links**: Entries without any link property are flagged
- **Confirm orphan removal**: Broken links might be fixable

## Files

- Backlog: @backlog.org (Current WIP section)
- Design docs: @docs/design/[0-9]*.org (for link validation)
- Evidence: git log, @CHANGELOG.md

## Example

```
/reconcile-backlog
```

Interactive reconciliation with confirmations and changes applied.

```
/reconcile-backlog --dry-run
```

Show what would change without modifying backlog.org.

## Related Commands

- `/reconcile-design-docs` - Reconcile design doc task statuses
- `/task-complete` - Manually mark a task complete
- `/task-hold` - Move a task to blocked status
