# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
