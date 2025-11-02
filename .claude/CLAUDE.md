# Claude Code Instructions

## Workflow Prompt

When a user requests a non-trivial task (anything requiring multiple steps or significant changes):

**Always ask first:** "Would you like me to follow the spec-driven development workflow? I can create a structured plan in `.claude/plan.md` and work through it systematically."

Options:
- **Yes**: Use `/plan new` to create a structured plan and follow the workflow defined in `.claude/commands/plan.md`
- **No**: Proceed directly with implementation (but still create a todo list for tracking)

For trivial single-step tasks, proceed directly without asking.

## Spec-Driven Development

This project uses a spec-driven approach: plan first, implement second.

### Workflow Pattern

See `/upgrade` command for the canonical example:

1. Create comprehensive plan in `.claude/plan.md`
2. Work through plan systematically. Add sub-lists of check-boxes as needed for complex tasks.
3. Mark items complete as you finish
4. When plan is done, update docs and delete plan

### File Purposes

`.claude/plan.md` - Active work only

- Current implementation tasks
- Phases and checkboxes
- Delete when complete

`.claude/tasks.md` - Future work

- Deferred features
- Ideas from abandoned plan items
- Reference for next session

`docs/` - Permanent knowledge

- `architecture.md` - design principles, system architecture (prime directive)
- `user-guide.md` - how to use the project
- `decisions/` - ADRs for significant choices

### When to Create ADRs

For significant architectural changes:

1. Create `docs/decisions/NNN-short-title.md`
2. Follow ADR template in `.claude/style.md`
3. Update `docs/decisions/README.md` index
4. Update `docs/architecture.md` if needed

## Git Commits

No Claude Code attributions in commits. Clean, professional messages only.

## Commands

Prefer just commands to simple bash. Projects should be run, tested, etc. via just whenever possible.

## Quick Reference

1. Read plan.md before starting
2. Mark tasks complete immediately
3. Update docs when done
4. Delete plan.md on completion or abandonment
