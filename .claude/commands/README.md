# Claude Commands

Custom slash commands for template and project management.

## Available Commands

### For Scaffolded Projects (Users)

#### `/upgrade`

Migrate this project to the latest template version using a spec-driven approach.

- Detects current template version
- Clones latest template for comparison
- Creates comprehensive migration plan
- Reviews all critical files (scripts, configs, .claude, .vscode, dotfiles)
- Works through changes systematically
- Tests and validates migration

Usage:

```
/upgrade
```

#### `/adapt`

Adapt this template to your project's specific needs using a spec-driven approach.

- Understands your requirements (language, framework, publishing)
- Creates comprehensive adaptation plan in plan.md
- Guides through customizations systematically
- Provides examples for common languages (Python, Node.js, Go, Docker)
- Tests and validates adaptations

Usage:

```
/adapt
```

#### `/adr-new`

Interactively create a new Architectural Decision Record (ADR).

- Guides through decision-making process
- Researches relevant context and options
- Presents alternatives with pros/cons
- Creates ADR with proper formatting
- Supports WIP (Work In Progress) status

Usage:

```
/adr-new
```

#### `/adr-capture`

Capture significant decisions from the current session as ADRs.

- Analyzes conversation for key decisions
- Identifies technology, architecture, and process choices
- Generates ADR files for each decision
- Updates ADR index automatically

Usage:

```
/adr-capture
```

#### `/docs`

Validate documentation for completeness and consistency.

- Checks documentation structure
- Validates internal links
- Verifies code examples
- Checks version references
- Finds TODOs and placeholders

Usage:

```
/docs
```

#### `/commit`

Create a git commit following conventional commit standards.

- Analyzes git status and diff to understand changes
- Drafts professional, concise commit message
- Follows conventional commits (feat, fix, docs, etc.)
- No self-attribution or branding
- Enforces 72 character limit and imperative mood

Usage:

```
/commit
```

#### `/review`

Perform a comprehensive code review and generate a review report.

- Reviews recent changes, specific files, or entire project
- Evaluates code quality, best practices, and architecture
- Generates .claude/review.md with findings and suggestions
- Presents code snippets and suggestions as diffs
- Automatically gitignored to avoid repository clutter

Usage:

```
/review
```

#### `/plan`

Manage project planning using `.claude/plan.md`.

- new: Create a new plan by exploring requirements and building a structured plan
- init: Initialize an empty plan template without starting the planning process
- refresh: Review existing plan and update checklist status
- pause: Create a summary section capturing insights from planning
- go: Execute or continue the existing plan using spec-driven development

Usage:

```
/plan new      # Start interactive planning session
/plan init     # Create empty plan template
/plan refresh  # Update plan status and verify completion markers
/plan pause    # Capture insights and context for resuming later
/plan go       # Execute the plan with spec-driven development flow
```

## How It Works

The `/upgrade` command provides a comprehensive, self-contained migration workflow:

1. Detects current version from `.envrc`
2. Clones latest template for comparison
3. Creates detailed migration plan
4. Reviews all files systematically
5. Tests and validates changes
