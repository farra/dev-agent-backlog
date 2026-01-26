---
name: setup
description: |
  Initialize the design doc backlog system in a project. Use when the user wants to:
  - Set up design docs for a project
  - Initialize the backlog system
  - Configure design doc workflow
  - Add design doc task management
---

# Setup Design Doc Backlog System

This skill helps users set up the design doc driven task management system in their project.

## When to Use

Activate when the user says things like:
- "set up design docs"
- "initialize the backlog"
- "configure design doc workflow"
- "add task management with design docs"

## Setup Process

### 1. Gather Information

Ask the user for:
- **Project prefix**: A short uppercase identifier (e.g., `ACME`, `GF`, `DAB`) used in task IDs like `[ACME-001-01]`

Check if they already have:
- A `README.org` with `#+PROJECT_PREFIX:` set (use that)
- Existing `docs/design/` directory (don't overwrite)
- Existing `backlog.org` (don't overwrite)

### 2. Create Directory Structure

Create these directories if they don't exist:
```
docs/design/
```

### 3. Create Files from Templates

The templates are in the plugin's `templates/` directory. Copy them with PROJECT substitution:

| Template | Destination | Substitution |
|----------|-------------|--------------|
| `readme-project.org` | `README.org` | Replace `PROJECT` with prefix |
| `readme-design.org` | `docs/design/README.org` | None |
| `org-setup.org` | `org-setup.org` | Replace `PROJECT` with prefix |
| `backlog-template.org` | `backlog.org` | Replace `PROJECT` with prefix |
| `design-doc-template.org` | `docs/design/000-template.org` | Replace `PROJECT` with prefix |
| `changelog-template.md` | `CHANGELOG.md` | None |

**Important**: Check if files exist before writing. Ask the user before overwriting.

### 4. Update CLAUDE.md

Append or merge the following into the project's CLAUDE.md (create if needed):

```markdown
## Design Doc Workflow

This project uses design docs for task management. Design docs live in `docs/design/`.

### Key Files
- `backlog.org` - Working surface for active tasks
- `docs/design/*.org` - Design documents (source of truth)
- `README.org` - Project config (prefix, categories, statuses)

### Workflow
1. Create design docs with `/backlog:new-design-doc`
2. Queue tasks with `/backlog:task-queue <id>`
3. Start work with `/backlog:task-start <id>`
4. Complete with `/backlog:task-complete <id>`

### Task ID Format
`[PREFIX-NNN-XX]` where:
- PREFIX = project prefix (e.g., ACME)
- NNN = design doc number
- XX = task sequence
```

### 5. Explain What Was Created

After setup, explain:
- What files were created and their purpose
- How to create a first design doc
- Available commands (`/backlog:new-design-doc`, etc.)

## Example Interaction

```
User: Set up design docs for this project

Claude: I'll help you set up the design doc backlog system.

What project prefix would you like to use? This is a short uppercase identifier
(like ACME, GF, or DAB) that will appear in task IDs like [ACME-001-01].

User: ACME

Claude: Great! Let me set up the backlog system with prefix ACME.

[Creates files...]

Done! I've created:
- README.org - Project config with categories and statuses
- org-setup.org - Shared org-mode configuration
- backlog.org - Your working surface for active tasks
- docs/design/README.org - Index of design documents
- docs/design/000-template.org - Template for new design docs
- CHANGELOG.md - For tracking releases

To create your first design doc, use:
  /backlog:new-design-doc "Your Feature Title"

This will create a numbered design doc with tasks you can then queue to your backlog.
```

## Template Content

When writing files, read the template content from the plugin's templates directory and perform the PROJECT → prefix substitution.
