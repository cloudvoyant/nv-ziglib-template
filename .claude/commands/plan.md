Help manage project planning using .claude/plan.md.

## Usage

- `/plan new` - Create a new plan by exploring requirements and building a structured plan
- `/plan init` - Initialize an empty plan template without starting the planning process
- `/plan refresh` - Review existing plan and update checklist status
- `/plan pause` - Create a summary section capturing insights from planning
- `/plan go` - Execute or continue the existing plan using spec-driven development
- `/plan done` - Mark current plan as complete and optionally commit changes

## Mode: init

### Step 1: Check for Existing Plan

Check if `.claude/plan.md` already exists:

- If it exists, inform the user and ask whether to:
  - Archive the existing plan (suggest filename: `.claude/plan-archived-YYYYMMDD.md`)
  - Overwrite the existing plan
  - Cancel the operation
- Wait for user decision before proceeding

### Step 2: Create Template

Create `.claude/plan.md` with the following template structure:

```markdown
# Plan

## Objective

[What are you trying to accomplish?]

## Phase 1 - [Phase Name]

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Phase 2 - [Phase Name]

- [ ] Task 1
- [ ] Task 2
```

### Step 3: Complete

After creating the template, inform the user and exit. Do not start the planning process.

## Mode: new

### Step 1: Check for Existing Plan

Check if `.claude/plan.md` already exists:

- If it exists, read the plan to check completion status
- Run `/plan refresh` logic to verify if all tasks are complete
- Based on status:
  - If plan is complete (all phases have ✅): Inform user the plan is complete and ask whether to:
    - Replace with new plan (no archiving needed)
    - Archive first then create new plan (suggest filename: `.claude/plan-completed-YYYYMMDD.md`)
    - Cancel the operation
  - If plan is incomplete: Inform user there's an incomplete plan and ask whether to:
    - Archive the existing plan and start fresh (suggest filename: `.claude/plan-incomplete-YYYYMMDD.md`)
    - Continue with the existing plan (redirect to `/plan go`)
    - Cancel the operation
- Wait for user decision before proceeding

### Step 2: Initialize Template

Create the empty plan template (same as init mode Step 2).

### Step 3: Understand the Goal

Ask: "What are you planning to build, implement, or accomplish?"

Wait for the user's response describing their objective.

### Step 4: Explore Requirements (Planning Mode)

Enter planning mode to explore the scope:

1. Clarify Requirements

   - Ask follow-up questions to understand scope and constraints
   - Identify key components or areas that need work
   - Understand dependencies and order of operations

2. Research Context

   - Search codebase for relevant files and patterns
   - Review existing architecture and structure
   - Identify files/systems that will be affected
   - Check for existing similar implementations

3. Break Down Work
   - Identify logical phases or groupings of work
   - For each phase, identify specific tasks
   - Consider dependencies between phases
   - Estimate complexity and risks

### Step 5: Create Structured Plan

Update `.claude/plan.md` with:

1. Objective Section

   - Concise 2-4 bullet points summarizing the goal
   - Focus on what, not how

2. Phase Sections
   - Group related tasks into phases
   - Name phases descriptively (e.g., "Phase 1 - Setup Infrastructure")
   - List specific, actionable tasks as unchecked items `- [ ]`
   - Keep tasks terse but clear
   - Order tasks logically within each phase

Format Requirements:

- Use `## Phase N - Description` for phase headers
- Use `- [ ]` for unchecked tasks
- Use `- [x]` for checked tasks (all start unchecked)
- Keep task descriptions concise (one line each)
- Add ✅ to phase header only when all tasks in that phase are complete

Example:

```markdown
# Plan

## Objective

Implement user authentication system:

- Support email/password and OAuth providers
- Include session management and token refresh
- Provide password reset flow

## Phase 1 - Core Authentication

- [ ] Design user schema and database models
- [ ] Implement password hashing and validation
- [ ] Create login/logout endpoints
- [ ] Add JWT token generation and validation
- [ ] **Run tests - verify Phase 1 complete**

## Phase 2 - OAuth Integration

- [ ] Configure OAuth providers (Google, GitHub)
- [ ] Implement OAuth callback handlers
- [ ] Link OAuth accounts to user profiles
- [ ] Handle account merging scenarios
- [ ] **Run tests - verify Phase 2 complete**

## Phase 3 - Session Management

- [ ] Implement refresh token rotation
- [ ] Add session expiration handling
- [ ] Create session invalidation endpoints
- [ ] Add "remember me" functionality
- [ ] **Run tests - verify Phase 3 complete**

## Phase 4 - Password Recovery

- [ ] Create password reset request endpoint
- [ ] Implement secure token generation
- [ ] Send password reset emails
- [ ] Create password reset confirmation endpoint
- [ ] **Run tests - verify Phase 4 complete**
```

### Step 6: Review

Present the plan and ask: "Does this plan cover everything? Any changes needed?"

Wait for confirmation or adjustments.

## Mode: refresh

### Step 1: Read Current Plan

Read `.claude/plan.md` and analyze:

- The objective and overall scope
- All phases and their tasks
- Current completion status (checked vs unchecked tasks)
- Phase completion markers (✅)

### Step 2: Verify Checklist Status

For each phase:

1. Count checked `[x]` vs unchecked `[ ]` tasks
2. Verify phase has ✅ marker if and only if all tasks are complete
3. Report any inconsistencies

### Step 3: Update Phase Markers

If status is inconsistent:

- Add ✅ to phase headers where all tasks are complete
- Remove ✅ from phase headers where tasks remain incomplete
- Update the file with corrections

### Step 4: Report Status

Provide a summary:

```
Plan Status:
- Phase 1 - Setup Infrastructure: 5/5 complete ✅
- Phase 2 - Core Features: 3/7 complete (in progress)
- Phase 3 - Testing: 0/4 complete (not started)

Overall: 8/16 tasks complete (50%)

Updated phase markers to reflect current status.
```

If the plan is fully complete, report completion:

```
Plan Status: All phases complete! ✅

Overall: 16/16 tasks complete (100%)

The plan is complete. Use /plan new to start a new plan.
```

## Mode: pause

### Step 1: Read Current Plan

Read `.claude/plan.md` to understand:

- The objective and scope
- All phases and their current status
- What has been completed
- What remains to be done
- Any context from the current session

### Step 2: Generate Insights Summary

Create a comprehensive "Insights" section capturing:

1. Progress Summary
   - What has been accomplished so far
   - Which phases are complete, in progress, or not started
   - Overall completion percentage

2. Key Decisions Made
   - Important choices made during planning or implementation
   - Rationale behind technical decisions
   - Trade-offs considered

3. Context and Findings
   - Important discoveries from codebase exploration
   - Dependencies and relationships identified
   - Constraints or limitations discovered

4. Next Steps
   - What should be done next when work resumes
   - Current task or phase in progress
   - Any blockers or considerations for continuation

5. Notes
   - Any other important context from the session
   - Tips for picking up work later
   - References to relevant files or documentation

### Step 3: Update Plan

Add or update the "Insights" section at the end of plan.md (before any archived sections):

```markdown
## Insights

Last Updated: 2025-10-15

Progress: Phase 2 in progress (8/16 tasks complete, 50%)

Key Decisions:
- Chose JWT for authentication instead of sessions (better for API-first architecture)
- Using bcrypt for password hashing (industry standard, well-tested)
- OAuth providers: Google and GitHub only (most common for our users)

Context:
- Existing user table has email field but needs password_hash column
- Found reusable token generation utility in src/utils/crypto.ts
- Session storage will use Redis (already configured in infrastructure)

Next Steps:
- Complete remaining tasks in Phase 2 (OAuth Integration)
- Test OAuth callback handlers with both providers
- Move to Phase 3 (Session Management)

Notes:
- Password reset emails require SMTP configuration (env vars in .envrc)
- Consider rate limiting for login attempts (add to Phase 5?)
```

### Step 4: Inform User

Report that the plan has been paused with insights captured, making it easy to resume work later.

## Mode: go

### Step 1: Read and Analyze Plan

Read `.claude/plan.md` to understand:

- The objective and full scope
- All phases and their tasks
- Current progress (what's checked vs unchecked)
- Any insights from previous sessions

### Step 2: Determine Starting Point

1. Check if there's an "Insights" section with next steps
2. Find the first unchecked task in the earliest incomplete phase
3. Report where execution will begin

Example:
```
Starting execution from Phase 2 - OAuth Integration
Next task: Configure OAuth providers (Google, GitHub)
```

### Step 3: Execute Spec-Driven Development Flow

For each task in the plan, follow this workflow:

#### 3.1: Before Starting a Task

1. Review the task and understand what needs to be done

2. **IMPORTANT:** Check if task is complex - if it requires multiple steps:
   - Break it down into sub-tasks as nested checkboxes
   - Update plan.md with sub-items:
   ```markdown
   - [ ] Configure OAuth providers (Google, GitHub)
     - [ ] Install OAuth library dependencies
     - [ ] Create OAuth configuration file
     - [ ] Add Google OAuth credentials to .envrc
     - [ ] Add GitHub OAuth credentials to .envrc
     - [ ] Test OAuth initialization
   ```

3. Create a spec (if task involves code):
   - Write a clear specification of what will be built
   - Define inputs, outputs, behavior
   - Identify affected files
   - Consider edge cases and error handling

4. Get approval before implementing (if accept edits is disabled):
   - Present the spec to the user
   - If accept edits is enabled, proceed directly to implementation
   - If accept edits is disabled, ask: "Does this approach look good? Any changes needed?" and wait for confirmation

#### 3.2: Implement the Task

1. Follow the spec precisely

2. Make necessary changes to code, configuration, or documentation

3. **CRITICAL:** Update checkboxes immediately as sub-tasks complete:
   ```markdown
   - [ ] Configure OAuth providers (Google, GitHub)
     - [x] Install OAuth library dependencies
     - [x] Create OAuth configuration file
     - [x] Add Google OAuth credentials to .envrc
     - [ ] Add GitHub OAuth credentials to .envrc
     - [ ] Test OAuth initialization
   ```

4. **Test the implementation:**
   - Run relevant tests (`just test`, unit tests, integration tests)
   - Manually verify functionality if needed
   - Ensure no regressions
   - Fix any test failures before marking task complete

#### 3.3: Mark Task Complete

1. Only mark complete when fully done:
   - All sub-tasks checked
   - **Tests passing** (critical - no exceptions)
   - Code working as specified

2. Update plan.md:
   ```markdown
   - [x] Configure OAuth providers (Google, GitHub)
   ```

3. Report completion and move to next task

#### 3.4: Pause at Phase Boundaries

When a phase is complete:

1. **CRITICAL: Run tests to validate phase completion:**
   - Run the project's test suite (`just test`, `just test-template`, or equivalent)
   - Verify all tests pass before marking phase complete
   - If tests fail, fix issues before proceeding
   - **Exception**: For complex refactoring, tests may be allowed to fail temporarily, but:
     - Document the failure reason in plan.md
     - Create specific tasks to fix tests in the next phase
     - State clearly why tests are allowed to remain broken

2. Mark phase as complete with ✅:
   ```markdown
   ## Phase 2 - OAuth Integration ✅
   ```

3. Report phase completion:
   ```
   Phase 2 - OAuth Integration complete! ✅

   Progress: 2/4 phases complete (50%)
   Tests: All passing ✅
   ```

4. Wait for user confirmation before starting next phase (if accept edits is disabled):
   - If accept edits is enabled, proceed directly to next phase
   - If accept edits is disabled, ask "Ready to move to Phase 3 - Session Management?" and wait for confirmation

5. Update Insights section if it exists (optional but recommended)

### Step 4: Handle Blockers

If a task cannot be completed:

1. Do not mark it as complete
2. Document the blocker in the Insights section
3. Ask the user how to proceed:
   - Skip and come back later?
   - Adjust the plan?
   - Need more information?

### Step 5: Continuous Updates

Throughout execution:

- Use TodoWrite tool to track immediate work items (detailed sub-steps)
- Keep plan.md updated with checkbox status (higher-level progress)
- TodoWrite is for current focus; plan.md is for overall progress

### Step 6: Completion

When all phases are complete:

1. Mark plan as complete in Insights section (if it exists)
2. Run `/plan refresh` to verify all checkboxes
3. Inform user the plan is complete and they can start a new plan with `/plan new`

## Mode: done

### Step 1: Verify Plan Completion

Read `.claude/plan.md` and verify completion status:

1. Run `/plan refresh` logic to check all tasks
2. Verify all phases have ✅ markers
3. Count total completed vs total tasks

If plan is not fully complete:
- Report incomplete status
- Ask user if they want to mark it done anyway or continue working
- Wait for confirmation

### Step 2: Offer to Commit Changes

Ask the user: "Would you like to commit the changes from this plan?"

Options:
- Yes - Proceed to create a commit
- No - Skip to Step 4 (Archive and Reset)
- Cancel - Exit without changes

### Step 3: Create Git Commit (if requested)

If user wants to commit:

1. Check git status to see what changed:
   ```bash
   git status
   git diff
   ```

2. Draft a commit message based on the plan objective and completed tasks:
   - Use the plan's objective as the basis for the commit message
   - Summarize the key changes from all phases
   - Follow conventional commit format if appropriate
   - Include the standard footer

3. Show the proposed commit message to the user

4. Ask: "Does this commit message look good?"
   - If yes: Create the commit
   - If no: Ask user for preferred message
   - If cancel: Skip to Step 4

5. Create the commit with all changes from the plan

### Step 4: Archive Completed Plan

Archive the current plan with completion date:

1. Suggest filename: `.claude/plan-completed-YYYYMMDD.md`
2. Ask: "Archive the completed plan to this file?"
   - If yes: Move plan.md to archive file
   - If no: Ask for preferred filename
   - If skip: Delete plan.md without archiving

3. Archive or delete the completed plan

### Step 5: Initialize Fresh Template

Create a new empty plan template (same as `/plan init` Step 2):

```markdown
# Plan

## Objective

[What are you trying to accomplish?]

## Phase 1 - [Phase Name]

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Phase 2 - [Phase Name]

- [ ] Task 1
- [ ] Task 2
```

### Step 6: Confirm Completion

Report to user:
```
Plan marked as complete! ✅

Commit: [Created/Skipped]
Archive: [filename or skipped]
New plan template ready at .claude/plan.md

Ready to start your next plan with /plan new or /plan go
```

## Spec-Driven Development Requirements

When implementing tasks during `/plan go`:

1. Always create a spec first for any code changes
2. Get user approval before implementing (skip if accept edits is enabled)
3. Follow the spec precisely during implementation
4. Test after each task to ensure quality
5. Update documentation as needed
6. Keep plan.md current with real-time checkbox updates

Example spec format:
```markdown
### Task: Implement password hashing and validation

Scope: Create utility functions for secure password handling

Files to modify:
- `src/utils/auth.ts` (create new file)
- `src/types/user.ts` (add password field types)

Implementation:
- Function `hashPassword(password: string): Promise<string>`
  - Uses bcrypt with cost factor 12
  - Returns hashed password string

- Function `validatePassword(password: string, hash: string): Promise<boolean>`
  - Compares password with stored hash
  - Returns true if match, false otherwise

Testing:
- Unit tests for both functions
- Test with various password lengths
- Test invalid inputs

Dependencies:
- Install bcrypt: `npm install bcrypt @types/bcrypt`
```

## Best Practices

- Terse but Clear: Tasks should be concise one-liners
- Actionable: Each task should be a specific action, not a vague goal
- Ordered: Tasks within phases should follow logical dependencies
- Grouped: Related tasks should be in the same phase
- Progressive: Phases should build on each other when possible
- Realistic: Don't create overly granular tasks; keep it manageable

## Notes

- Plan.md is for active planning; use `/plan new` to replace completed plans
- The objective should be stable; phases and tasks can evolve
- Use `/plan refresh` periodically to keep status accurate
- When a phase is complete, mark it with ✅ in the header
- Consider creating new plans for major direction changes rather than constantly editing
- Archiving completed plans is optional; `/plan new` can replace them directly
