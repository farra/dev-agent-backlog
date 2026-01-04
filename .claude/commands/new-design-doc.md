---
description: Create a new design document (from template or by converting markdown)
argument-hint: <title> [source.md]
---

# New Design Doc

Create a new design document titled: **$ARGUMENTS**

## Argument Parsing

Parse `$ARGUMENTS` to extract:
- **title**: The design doc title (required)
- **source_path**: Optional path to existing markdown file to convert

Examples:
- `/new-design-doc Error Recovery` → title="Error Recovery", no source
- `/new-design-doc Error Recovery docs/legacy/error-handling.md` → title="Error Recovery", source="docs/legacy/error-handling.md"

## Process

### 1. Find Next Available Number

Look at existing files in `docs/design/` to find the next available NNN:
- List files matching `[0-9][0-9][0-9]-*.org`
- Find the highest number
- Use the next number (or suggest based on category)

Number ranges:
| Range   | Category           |
|---------|-------------------|
| 001-099 | Core system       |
| 100-199 | Features          |
| 200-299 | Infrastructure    |
| 300-399 | Tooling           |
| 800-899 | Analysis/Research |
| 900-999 | Proposals/Future  |

### 2. Create the Document

**If no source_path** (new from template):
- Copy from `docs/design/000-template.org`
- Fill in header properties (see below)

**If source_path provided** (convert from markdown):
- Read the markdown file
- Convert to org-mode format (see Conversion Rules below)
- Preserve existing content structure

Fill in header:
- `#+TITLE:` - NNN - <title>
- `#+AUTHOR:` - Your Name (or prompt for author)
- `#+STATUS:` - Draft
- `#+CREATED:` - Today's date [YYYY-MM-DD]
- `#+LAST_MODIFIED:` - Today's date
- `#+SETUPFILE: ../../org-setup.org`

### 3. Assign Task IDs

For **new documents**: Use placeholder pattern `[PROJECT-NNN-01]`, `[PROJECT-NNN-02]`, etc.

For **converted documents**:
- Find all `- [ ]` and `- [x]` checkboxes
- Convert to `** TODO [PROJECT-NNN-XX]` / `** DONE [PROJECT-NNN-XX]`
- Assign sequential IDs starting at 01
- Preserve the task description text

### 4. Update README.org Index

If `docs/design/README.org` exists:
- Find the appropriate section based on number range
- Add a new row to the table: `| NNN | [[file:NNN-slug.org][Title]] | Draft |`

### 5. Offer to Queue Tasks

After conversion, offer to queue extracted tasks to `backlog.org`:
- List the tasks found with their new IDs
- Ask if user wants to queue any/all to Active section

### 6. Report

Output:
- Path to new file
- If converted: summary of what was transformed
- List of tasks with their IDs
- Remind to review and refine

## Conversion Rules (Markdown → Org-Mode)

### Structure
| Markdown | Org-Mode |
|----------|----------|
| `# Heading` | `* Heading` |
| `## Heading` | `** Heading` (under appropriate parent) |
| `### Heading` | `*** Heading` |

### Tasks
| Markdown | Org-Mode |
|----------|----------|
| `- [ ] Task text` | `** TODO [PROJECT-NNN-XX] Task text` |
| `- [x] Task text` | `** DONE [PROJECT-NNN-XX] Task text` |

### Code
| Markdown | Org-Mode |
|----------|----------|
| ` ```rust` | `#+begin_src rust` |
| ` ``` ` | `#+end_src` |

### Frontmatter
| Markdown YAML | Org-Mode |
|---------------|----------|
| `title: X` | `#+TITLE: X` |
| `status: X` | `#+STATUS: X` |
| `author: X` | `#+AUTHOR: X` |

### Questions/Decisions
| Markdown Pattern | Org-Mode |
|------------------|----------|
| `**Open Question:**` or `- [ ] Question?` in Questions section | `** OPEN Question?` |
| `**Decision:**` or `- [x] Decided thing` in Questions section | `** DECIDED Decided thing` |

### Links
| Markdown | Org-Mode |
|----------|----------|
| `[text](url)` | `[[url][text]]` |
| `[text](./file.md)` | `[[file:file.org][text]]` (update .md → .org) |

## Org-Mode Reminders

The document MUST use org-mode conventions:
- `** TODO [PROJECT-NNN-XX] Task title` for tasks (not markdown checkboxes)
- `** OPEN` / `** DECIDED` for questions
- `:PROPERTIES:` drawers for metadata (EFFORT, VERSION, etc.)
- `#+SETUPFILE: ../../org-setup.org` for shared config

## Examples

New from template:
```
/new-design-doc Error Recovery Improvements
```
Creates `docs/design/019-error-recovery-improvements.org`

Convert existing markdown:
```
/new-design-doc Cache Architecture docs/legacy/caching-proposal.md
```
Converts markdown to `docs/design/020-cache-architecture.org`, assigns task IDs

## Files

- Template: `docs/design/000-template.org`
- Index: `docs/design/README.org`
- Setup: `org-setup.org`
- Backlog: `backlog.org` (for queuing extracted tasks)
