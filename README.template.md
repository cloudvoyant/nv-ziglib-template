# {{PROJECT_NAME}}

> A new project scaffolded from {{TEMPLATE_NAME}} (v{{TEMPLATE_VERSION}})

## Overview

[Add your project description here]

### Project Structure

```
.
├── docs/          # Documentation
├── scripts/       # Utility scripts and CI/CD hooks
├── src/           # Zig source code
├── build.zig      # Zig build configuration
├── build.zig.zon  # Zig package manifest
├── justfile       # Build recipes
├── .envrc         # Key env vars and shell config
└── version.txt    # Project version
```

## Prerequisites

- bash 3.2+
- just
- Zig 0.15.1 or later
- [List other project-specific dependencies]

## Setup

Run `just setup` or `./scripts/setup.sh` to install remaining dependencies (just, direnv, Zig).

Optional: `just setup --dev` for development tools (ZLS language server, shellcheck, shfmt, etc.).

## Quick Start

Type `just` to see all the tasks at your disposal:

```bash
❯ just
Available recipes:
    [dev]
    load                 # Load environment
    install              # Install dependencies
    build                # Build the project
    run                  # Run project locally
    test                 # Run tests
    clean                # Clean build artifacts

[ OUTPUT TRUNCATED ]
```

Build run and test with `just`.

```bash
❯ just run

❯ just test

```

Just runs the necessary dependencies for a task on it's own!

## Publishing

Commit using conventional commits (`feat:`, `fix:`, `docs:`). Merge/push to main and CI/CD will run automatically bumping your project version and publishing a package.

### Release Process

1. **Make changes** on a feature branch
2. **Commit with conventional commits**:
   - `feat: add new feature` → minor version bump
   - `fix: resolve bug` → patch version bump
   - `feat!: breaking change` or `BREAKING CHANGE:` in footer → major version bump
3. **Push to GitHub** and create a pull request
4. **Merge to main** - the CI/CD pipeline will:
   - Run tests
   - Build artifacts
   - Generate changelog
   - Create GitHub release
   - Publish to registry (if configured)

### Manual Publishing

To publish manually:

```bash
# Ensure you're on main branch with clean working directory
just publish
```

This will publish a pre-release package version.

### Registry Configuration

Publishing is configured for both GitHub Releases (binaries) and optionally GCP Artifact Registry.

**GitHub Releases** (default):
- Multi-platform binaries are automatically built and uploaded to GitHub Releases
- Users can install with: `curl -sSL https://github.com/YOUR_ORG/{{PROJECT_NAME}}/raw/main/install.sh | bash`

**GCP Artifact Registry** (optional):
- Configure in `.envrc`: Set `GCP_REGISTRY_PROJECT_ID`, `GCP_REGISTRY_REGION`, `GCP_REGISTRY_NAME`
- Add `GCP_SA_KEY` secret to GitHub repository for automated publishing

**Using as a library:**
- Other Zig projects can import this as a dependency:

```bash
# Use a specific version (recommended for production)
zig fetch --save "git+https://github.com/YOUR_ORG/{{PROJECT_NAME}}#vX.Y.Z"

# Or track the latest changes on main
zig fetch --save "git+https://github.com/YOUR_ORG/{{PROJECT_NAME}}#main"
```

Then in your `build.zig`:
```zig
const {{PROJECT_NAME}} = b.dependency("{{PROJECT_NAME}}", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("{{PROJECT_NAME}}", {{PROJECT_NAME}}.module("{{PROJECT_NAME}}"));
```

See the [{{TEMPLATE_NAME}} Development Guide](https://github.com/your-org/{{TEMPLATE_NAME}}/blob/main/docs/development-guide.md) for detailed configuration instructions.

## Documentation

To learn more about using this template, read the docs:

- [Development Guide](docs/development-guide.md) - Complete setup and usage guide
- [Infrastructure](docs/infrastructure.md) - Design and implementation details

## References

- [Zig Language](https://ziglang.org/)
- [Zig Build System](https://ziglang.org/learn/build-system/)
- [Zig Package Manager](https://github.com/ziglang/zig/wiki/Package-Manager)
- [ZLS (Zig Language Server)](https://github.com/zigtools/zls)
- [just command runner](https://github.com/casey/just)
- [direnv environment management](https://direnv.net/)
- [semantic-release](https://semantic-release.gitbook.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
