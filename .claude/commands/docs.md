Validate documentation for completeness, consistency, and accuracy.

## Validation Steps

### 1. Validate Project-Specific Content

Verify documentation matches the actual project state:

```bash
# Check that documented files exist
ls -la .envrc justfile package.json setup.py Cargo.toml 2>/dev/null

# Verify documented directories exist
ls -la src/ docs/ test/ .github/ 2>/dev/null

# Check documented commands work
command -v just git docker node python go 2>/dev/null
```

For the project:

- Design and architecture docs accurately reflect the implementation
- Installation instructions match actual setup requirements
- Configuration file examples match actual file structure
- Documented commands actually exist and work
- File paths in examples point to real files
- Directory structure matches what's documented
- Dependencies listed match actual requirements files
- Environment variables match .envrc or similar config
- Example code is accurate and reflects current implementation
- Contributing guidelines are present (if accepting contributions)

### 2. Validate Documentation Readability

Check whether the documentation is concise and readable.

- Project readme should be to the point for template clients and maintainers
- Template readme should be appropriate for client projects
- User guide should be readable and easy to follow, utilize progressive disclosure
- Architecture documentation should provide meaningful design descriptions or component breakdown for maintainers, and explicitly state important implementation details accurately

### 3. Check Documentation Structure

Verify documentation files exist:

```bash
ls -la docs/ README.md
```

Common documentation files to look for:

- `README.md` - Main project documentation
- User guides, tutorials, or getting started docs
- Architecture or design documentation
- API or usage documentation
- Contributing guidelines
- Changelog or release notes

### 4. Validate Internal Links

Check for broken internal links in documentation:

```bash
# Find all markdown links
grep -r "\[.*\](.*/.*\.md)" docs/ README.md
```

For each link found:

- Verify the target file exists
- Check if section anchors are valid (if present)

### 5. Check Cross-References

Verify documentation cross-references are consistent:

- Check that main documentation references related guides
- Verify that related documents link to each other appropriately
- Ensure index files (if present) list all related documents

### 6. Validate Code Examples

Check code examples in documentation match the actual project:

```bash
# Extract just commands from docs
grep -r "just [a-z-]*" docs/ README.md

# Compare with actual justfile
just
```

For each command or code example:

- Verify syntax is correct for the language
- Check that file paths referenced actually exist in the project
- Ensure bash/just commands are accurate and exist
- Verify configuration examples match actual config files
- Check that code snippets reflect current implementation

### 7. Validate TODOs and Placeholders

Find any TODOs or placeholders that need attention:

```bash
grep -r "TODO" docs/ README.md
grep -r "FIXME" docs/ README.md
grep -r "{{.*}}" docs/ README.md
```

Review each TODO:

- Is it still relevant?
- Should it be tracked as an issue?
- Can it be resolved now?

### 8. Check Markdown Formatting

Verify markdown syntax is valid:

- Headers are properly formatted (# ## ###)
- Code blocks have language tags
- Lists are consistently formatted
- Tables are properly aligned
- No trailing whitespace

## Report Findings

Summarize validation results:

```
Documentation Validation Report
================================

✓ Structure: All required files present
✓ Internal Links: X/Y links validated
✗ Code Examples: 2 commands need updating
✗ Project Consistency: 3 documented commands don't exist
⚠ Version References: Found 1 outdated reference
✓ TODOs: 3 TODOs found (all tracked)
✓ Markdown: No formatting issues
```

For each issue found:

- Describe the problem (e.g., "docs reference `just deploy` but command doesn't exist in justfile")
- Suggest a fix (e.g., "Add `just deploy` command or update docs to reference correct command")
- Indicate priority (high/medium/low)

Key consistency checks:

- All documented commands exist and work
- File paths in examples point to real files
- Configuration examples match actual config structure
- Version numbers are consistent across all files
- Dependencies match actual requirement files
