Perform a comprehensive code review and generate a review.md report.

## Workflow

### Step 1: Determine Review Scope

Ask the user what to review:

- Recent changes - Review uncommitted changes or recent commits
- Specific files - Review particular files or directories
- Entire project - Full codebase review
- Pull request - Review changes in a PR

Wait for user to specify scope.

### Step 2: Analyze Code

Based on scope, analyze:

For recent changes:
```bash
git diff
git status
```

For specific files:
- Read the specified files
- Understand their purpose and context

For entire project:
- Review key files (justfile, scripts/, src/, lib/, main code)
- Focus on architecture, patterns, and conventions

For pull requests:
```bash
git diff main...HEAD
```

### Step 3: Review Criteria

Evaluate code against these criteria:

Code Quality:
- Readability and clarity
- Proper naming conventions
- Code duplication
- Complexity (functions too long/complex?)
- Error handling

Best Practices:
- Follows project conventions (check .claude/style.md)
- Proper use of language idioms
- Security considerations
- Performance concerns

Architecture:
- Separation of concerns
- Modularity and reusability
- Consistency with existing patterns

Documentation:
- Code comments where needed (not obvious)
- Function/module documentation
- README/docs updated if needed

Testing:
- Tests exist and are appropriate
- Edge cases covered
- Test quality and clarity

Bash-specific (if applicable):
- Follows Google Shell Style Guide
- Proper error handling (set -euo pipefail)
- Quoting variables correctly
- No external dependencies (jq, yq, etc.)

### Step 4: Generate Review Report

Create `.claude/review.md` with this structure:

```markdown
# Code Review

Date: YYYY-MM-DD
Scope: [What was reviewed]
Reviewer: Claude Code

## Summary

[High-level overview: 2-3 sentences about overall code quality]

## Findings

### Critical Issues

[Issues that must be fixed - security, bugs, breaking changes]

#### Issue: [Title]

File: `path/to/file.ext:line`

Problem:
[Description of the issue]

Current code:
\```language
[Code snippet showing the problem]
\```

Suggested fix:
\```diff
- old line
+ new line
\```

Rationale:
[Why this change is needed]

---

### Improvements

[Non-critical improvements - readability, performance, style]

#### Suggestion: [Title]

File: `path/to/file.ext:line`

Current code:
\```language
[Code snippet]
\```

Suggested improvement:
\```diff
- old approach
+ better approach
\```

Benefit:
[Why this would be better]

---

### Positive Observations

[Good patterns, well-written code, things done right]

- [Specific example of good practice]
- [Another positive point]

## Recommendations

1. [Prioritized action item]
2. [Another recommendation]
3. [Additional suggestion]

## Conclusion

[Final assessment and next steps]
```

### Step 5: Ensure .gitignore

Check if `.claude/review.md` is in `.gitignore`:

```bash
grep -q "\.claude/review\.md" .gitignore || echo ".claude/review.md" >> .gitignore
```

If not present, add it and inform user.

### Step 6: Report Completion

Inform user:
```
Code review complete! ✅

Review saved to: .claude/review.md

Summary:
- X critical issues found
- Y improvements suggested
- Z positive observations

Next steps:
1. Review the findings in .claude/review.md
2. Address critical issues first
3. Consider implementing suggested improvements
```

## Review Guidelines

Be constructive:
- Focus on the code, not the person
- Explain the "why" behind suggestions
- Acknowledge good patterns and practices

Be specific:
- Reference exact file paths and line numbers
- Provide concrete examples
- Show before/after code

Be practical:
- Prioritize issues (critical vs. nice-to-have)
- Consider project constraints and conventions
- Don't suggest changes that violate project style

Be thorough but focused:
- Don't nitpick every minor detail
- Focus on meaningful improvements
- Balance perfectionism with pragmatism

## Code Snippet Format

Always use markdown code blocks with language tags:

For showing current code:
\```bash
current_function() {
    echo "example"
}
\```

For showing suggestions:
\```diff
- old_function() {
-     echo "old way"
+ new_function() {
+     echo "better way"
  }
\```

For context:
\```bash
# Function that does X
function_name() {
    # This part is fine
    good_code

    # This part needs work (see review)
    problematic_code
}
\```

## Notes

- Review file is gitignored to avoid cluttering repository
- Reviews are snapshots - regenerate for updated code
- Use `/review` periodically during development
- Combine with `/commit` workflow for quality assurance
