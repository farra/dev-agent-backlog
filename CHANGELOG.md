# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- **Claude Tasks integration**: backlog.org now serves as universal hub linking to Claude Tasks
- `/backlog:task-link` command to add link properties to existing backlog tasks
- `claude-tasks-sync` skill to ensure Claude Tasks are cross-referenced in backlog.org
- `:CLAUDE_TASK:` property for linking backlog entries to Claude Tasks
- `/queue-design-doc` now creates Claude Task List and enters plan mode

### Changed
- Renamed `:SOURCE:` property to `:DESIGN:` (now optional, for hub model)
- `task-start` now creates Claude Task at execution time for coordination
- `backlog-resume` surfaces Claude Task links when resuming work
- All link properties (`:DESIGN:`, `:CLAUDE_TASK:`, `:GITHUB:`, `:BEAD:`) are optional
- Tasks can now originate directly in backlog.org without a design doc

### Documentation
- Updated project framing: two core pillars (backlog as hub, design docs for planning)
- Added composability documentation (design-review vs queue-design-doc workflows)
- Clarified sync means cross-references, not content replication

## [2.0.0] - 2026-01-26

This release transforms dev-agent-backlog from a shell-script-installed template
into a proper Claude Code plugin with marketplace distribution.

### Added
- **Claude Code Plugin**: Install via `/plugin marketplace add farra/dev-agent-backlog`
- **Marketplace distribution**: This repo is now a Claude Code marketplace
- **`/backlog:setup` skill**: Interactive project initialization replacing `init.sh`
- **Plugin README**: Documentation for plugin installation and usage
- **Namespaced commands**: All commands now prefixed with `backlog:` (e.g., `/backlog:task-queue`)
- `/design-review` command to guide docs through Draft → Review → Accepted flow
- `/queue-design-doc` command to queue all tasks from a design document with pre-flight checks
- Sequential document numbering with `#+CATEGORY:` classification (replaces category ranges)
- Document status lifecycle: Draft → Review → Accepted → Active → Complete → Archived
- Research on other coding agents (Codex, Gemini CLI, OpenCode) - methodology is portable

### Changed
- **Installation method**: Use plugin system instead of `bin/init.sh`
- Commands migrated from `.claude/commands/` to `plugin/commands/`
- Skills migrated from `.claude/skills/` to `plugin/skills/`
- Templates moved to `plugin/templates/`
- `init.sh` now shows deprecation warning pointing to plugin

### Deprecated
- `bin/init.sh` - Use `/backlog:setup` skill instead

### Migration
If upgrading from 1.x:
1. Install the plugin: `/plugin marketplace add farra/dev-agent-backlog`
2. Install: `/plugin install backlog@dev-agent-backlog`
3. Commands are now namespaced: `/task-queue` → `/backlog:task-queue`
4. Your existing org files and backlog continue to work unchanged

## [1.0.1] - 2026-01-04

### Added
- Handoff notes (`:HANDOFF:` property) for session continuity
- Work attribution (`:WORKED_BY:`, `:COMPLETED_BY:` properties)
- Transcript linking (`:TRANSCRIPT:` property) on task completion
- `backlog-resume` skill for automatic task resumption on session start
- CHANGELOG.md following keepachangelog format
- Design docs 005 (gastown features) and 006 (changelog workflow)

### Changed
- `task-queue` command adds `:HANDOFF:` and `:WORKED_BY:` properties
- `task-start` command displays handoff notes and updates `:WORKED_BY:`
- `task-complete` command prompts for attribution and changelog entry
- `backlog-update` skill checks CHANGELOG.md before commits

## [1.0.0] - 2026-01-04

### Added
- Initial task management system for human-agent collaboration
- Design document workflow (RFC/RFD pattern)
- Backlog working surface with checkout/reconcile pattern
- Slash commands: `/task-queue`, `/task-start`, `/task-complete`, `/task-hold`, `/new-design-doc`
- Proactive skills: `backlog-update`, `new-design-doc`
- Emacs integration with `dab-task-queue` and `dab-goto-source`
- Bootstrap script (`bin/init.sh`) for new projects
- Design docs 001-004 documenting system architecture
