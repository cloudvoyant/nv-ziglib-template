# Architecture

## Overview

`nv-ziglib-template` is a production-ready Zig project template with automated versioning, multi-platform binary distribution, and GitHub Actions CI/CD. Build CLI tools or libraries with cross-compilation support for Linux, macOS, and Windows.

The template integrates Zig's native build system (build.zig) with a portable bash framework for CI/CD automation. Multi-platform binaries are published to GitHub Releases by default, with optional GCP Artifact Registry support for enterprise distribution.

## How It Works

The template integrates Zig with portable automation:

```
┌────────┐    ┌──────┐    ┌─────────┐    ┌────────────────┐
│ direnv │ -> │ just │ -> │   Zig   │ -> │ GitHub Actions │
└────────┘    └───┬──┘    └─────────┘    └────────────────┘
                  │
                  v
            ┌───────────┐
            │  scripts  │
            └───────────┘
```

When you run a command like `just build`, here's what happens:

1. direnv automatically loads `.envrc` to populate your environment with PROJECT, VERSION, and registry configuration
2. just executes the command you specified (`just build`, `just test`, `just publish`) using recipes defined in the `justfile`
3. The justfile recipes call Zig commands (`zig build`, `zig fmt`, `zig build test`) for all Zig-specific operations
4. The justfile also calls bash scripts in `scripts/` for cross-language automation (`setup.sh`, `scaffold.sh`, `upversion.sh`)
5. GitHub Actions workflows trigger on PRs and merges, calling your just commands to run tests and publish releases

## Design / Basic Usage

### Getting Started

For detailed setup instructions, see the [User Guide](user-guide.md#quick-start).

After scaffolding a project from this template, you have a working Zig project ready to build. Interact with your project via `just` commands:

```bash
just install    # Fetch Zig dependencies
just build      # Build with Zig (debug mode)
just test       # Run Zig tests
just format     # Format code with zig fmt
just publish    # Build all platforms + publish binaries
```

To customize CI/CD behavior, edit scripts in the `scripts/` directory rather than modifying workflows directly.

### Zig Integration

The template is fully configured for Zig 0.15.1:

build.zig:
- Defines build configuration (library, executable, or both)
- Configures cross-compilation targets
- Sets up test suite

build.zig.zon:
- Declares project metadata (name, version)
- Manages dependencies (fetched from GitHub tarballs)

justfile:
- `build` → `zig build`
- `test` → `zig build test --summary all`
- `format` → `zig fmt src/ build.zig`
- `build-platform` → `zig build -Dtarget=<target>`

The key principle: Zig handles all language-specific operations, justfile provides the interface, bash scripts handle cross-language concerns (versioning, scaffolding, setup). This separation keeps Zig idioms pure while maintaining portable automation.

## Project Structure

### Template (This Repo)

For template maintainers. Includes testing infrastructure:

```
lib/
├── .envrc                   # Environment variables
├── justfile                 # Commands + TEMPLATE section
├── Dockerfile               # Docker image definition
├── docker-compose.yml       # Docker services configuration
├── scripts/                 # Bash framework
│   ├── setup.sh
│   ├── scaffold.sh
│   └── upversion.sh
├── src/                     # Sample code
├── test/                    # bats tests (for template)
├── docs/                    # architecture.md, user-guide.md
├── .claude/                 # AI workflows + all commands
├── .github/workflows/       # ci.yml, release.yml
└── .devcontainer/           # VS Code container
```

### Scaffolded Projects

For end users. Template development files removed:

```
myproject/
├── .envrc                   # Your project config
├── justfile                 # Clean commands (no TEMPLATE section)
├── Dockerfile               # Docker image definition
├── docker-compose.yml       # Docker services configuration
├── scripts/                 # Bash framework (override as needed)
├── src/                     # Your code here
├── docs/                    # Your docs
├── .claude/                 # User-facing commands only
├── .github/workflows/       # ci.yml, release.yml
└── .devcontainer/           # VS Code container
```

Key difference: The main README.md documents template architecture and is kept in the template repository. During scaffolding, `README.template.md` is renamed to `README.md` in the new project and customized with project-specific information. Template development files (`test/`, `.claude/commands/upgrade.md`, etc.) are removed.

## Implementation Details

This section is for template maintainers and advanced users who need to understand how components work internally.

### Component: justfile

The `justfile` serves as the command runner interface, providing a consistent command experience across all projects regardless of language. It uses bash as the shell interpreter and defines color variables (INFO, SUCCESS, WARN, ERROR) for pretty output. The `_load` recipe sources `.envrc` to load environment variables, and all other recipes depend on it to ensure consistent configuration.

Recipe dependencies create a build chain (`test` depends on `build`, `publish` depends on both `test` and `build-prod`) that enforces quality gates automatically. This prevents common mistakes like publishing untested code, improving developer confidence and reducing production incidents.

### Component: scripts/

The `scripts/` directory contains language-agnostic bash automation, isolating platform-specific complexity from your project code. This design allows the template to support any language while maintaining consistent workflows.

- `setup.sh` - Installs dependencies using semantic flags (`--dev`, `--ci`, `--template`) that clearly communicate intent and avoid installing unnecessary tools in CI environments
- `scaffold.sh` - Initializes new projects from the template, handling case variant replacements (PascalCase, camelCase, etc.), template cleanup, and backup/restore on failure to ensure safe initialization
- `upversion.sh` - Wraps semantic-release with a consistent interface (local dry-run mode vs CI mode), enabling developers to preview version bumps before pushing
- `utils.sh` - Provides shared functions for logging, version reading, and cross-platform compatibility, reducing code duplication and maintenance burden

All scripts use `set -euo pipefail` for fail-fast behavior, catching errors immediately rather than continuing with invalid state.

### Component: .envrc

The `.envrc` file holds environment configuration that direnv loads automatically, eliminating the need to manually export variables or pass flags to commands. This improves DX by making environment consistent across terminal sessions and reducing context-switching friction.

Keep it simple with just `export` statements - no bash logic. This constraint prevents complex logic from hiding in configuration, making projects easier to debug. Secrets belong in GitHub Secrets, not `.envrc`, following security best practices. Each project commits its own `.envrc` file for reproducibility. The `.envrc.template` file provides a starting point for scaffolded projects with placeholders that `scaffold.sh` replaces.

### Component: GitHub Actions

Two workflows handle CI/CD with minimal configuration: `ci.yml` runs `just build` and `just test` on pull requests, while `release.yml` runs semantic-release on main branch and then `just publish` if a new version was created.

The workflows call your just commands rather than duplicating logic, creating a single source of truth. This design means you can test CI behavior locally (`just test` runs the same way everywhere), debug faster, and upgrade workflows without touching project-specific logic. Customization happens in familiar territory (bash scripts and just recipes) rather than GitHub Actions YAML.

### Component: Claude Commands

Claude commands provide LLM-assisted workflows for complex tasks. For complete command documentation and usage examples, see [.claude/commands/README.md](../.claude/commands/README.md).

- `/upgrade` - Migrates projects to newer template versions using a spec-driven approach with comprehensive plans
- `/adapt` - Customizes the template for your language/framework with examples for Python, Node.js, Go, Docker
- `/adr-new`, `/adr-capture` - Documents architectural decisions in `docs/decisions/`
- `/docs` - Validates documentation completeness and consistency
- `/commit` - Creates conventional commits with proper formatting
- `/review` - Performs comprehensive code reviews with detailed reports
- `/plan` - Manages project planning with spec-driven development

### Component: Dockerfile (Multi-Stage)

The `Dockerfile` uses a multi-stage build to support both minimal runtime environments and full development environments from a single file:

#### Base Stage (`target: base`)

- Used by docker-compose for `just docker-run` and `just docker-test`
- Installs essential dependencies: bash, just, direnv, Zig 0.15.1
- Zig installed via setup.sh for consistency with local development
- Fast build time (~3-5 minutes including Zig download)
- Minimal image size for quick iteration

#### Dev Stage (`target: dev`)

- Used by VS Code DevContainers
- Builds on top of base stage
- Adds development tools: docker, node/npx, gcloud, shellcheck, shfmt, claude
- Adds template testing tools: bats-core
- ZLS (Zig Language Server) installed via VS Code Zig extension
- Slower build (~12 minutes), but cached after first build

Configuration:
- `docker-compose.yml` services specify `target: base` for fast builds
- `.devcontainer/devcontainer.json` specifies `target: dev` for full Zig development
- Both share the same base layers, maximizing Docker layer cache efficiency
- Zig cache directories (.zig-cache, ~/.cache/zig) preserved across builds

### Component: docker-compose.yml

Provides containerized services for running and testing without installing dependencies locally:

- `runner` service: Executes `just run` in isolated container
- `tester` service: Executes `just test` in isolated container
- Both use `target: base` for minimal, fast builds
- Mount project directory to `/workspace` for live code updates

### Component: .devcontainer/

The `.devcontainer/` directory provides VS Code Dev Containers configuration for consistent Zig development environments across teams. The devcontainer uses the root-level `Dockerfile` with `target: dev` to build a full development environment.

Features:
- `git:1` - Git installed from source (credentials auto-shared by VS Code via SSH agent forwarding)
- `docker-outside-of-docker:1` - Docker CLI that connects to host's Docker daemon

Credential Mounting:
- Claude CLI credentials mounted from `~/.claude` directory
- Uses cross-platform path resolution: `${localEnv:HOME}${localEnv:USERPROFILE}` expands to HOME on Unix or USERPROFILE on Windows
- Git/GitHub credentials automatically forwarded via SSH agent (requires `ssh-add` on host)
- gcloud requires manual `gcloud auth login` inside container (credentials persist via Docker volumes)

VS Code Extensions:
- `ziglang.vscode-zig` - Zig language support (syntax highlighting, autocomplete, ZLS integration)
- `mkhl.direnv` - direnv support
- `skellock.just` and `nefrob.vscode-just-syntax` - justfile syntax highlighting
- `timonwong.shellcheck` and `foxundermoon.shell-format` - Shell script linting and formatting
- `ms-azuretools.vscode-docker` - Docker support

Zig Development:
- Zig 0.15.1 pre-installed in dev stage
- ZLS (Zig Language Server) automatically installed by vscode-zig extension
- Provides: autocomplete, go-to-definition, inline diagnostics, formatting on save
- Zig cache (.zig-cache, ~/.cache/zig) preserved via Docker volumes

Cross-Platform Considerations:
- Works on macOS, Linux, and Windows (via Docker Desktop or WSL)
- Credential paths use environment variable fallback pattern for platform compatibility
- On Windows, if `~/.claude` doesn't exist at `%USERPROFILE%\.claude`, mount will fail gracefully (container starts without Claude credentials)

### Setup Flags

The `setup.sh` script uses semantic flags to indicate what level of tooling to install (also documented in [User Guide](user-guide.md#getting-started)):

```bash
just setup              # Required: bash, just, direnv
just setup --dev        # + docker, node/npx, gcloud, shellcheck, shfmt, claude
just setup --ci         # + node/npx, gcloud (for release automation)
just setup --template   # + bats-core (template testing)
```

This approach makes dependencies explicit and context-aware. Developers get linting and formatting tools (`--dev`), CI environments install only what's needed for builds (`--ci`), and template maintainers get testing frameworks (`--template`). This reduces CI build times, prevents tool version conflicts, and makes onboarding clearer ("run `just setup --dev` to get started").

### Publishing

The template publishes multi-platform Zig binaries to two destinations:

GitHub Releases (Primary - Always Active):
- Multi-platform binaries automatically uploaded to GitHub Releases
- No configuration needed (uses GITHUB_TOKEN)
- Supports: Linux (x86_64, aarch64), macOS (x86_64, aarch64), Windows (x86_64)
- Binary naming: `project-os-arch` (e.g., `nv-ziglib-template-linux-x86_64`)
- Users install via `install.sh` or manual download

GCP Artifact Registry (Optional - Enterprise):
- Individual platform binaries uploaded to GCP generic repository
- Only runs if GCP_SA_KEY secret is configured
- Same binaries as GitHub Releases, different distribution channel
- Useful for internal/enterprise distribution

Publishing flow:
1. `just build-all-platforms` → Builds 5 platform binaries to zig-out/bin/
2. GitHub Release step → Uploads zig-out/bin/* to release
3. `just publish` → Uploads individual binaries to GCP (if configured)

Version management:
- version.txt is the canonical version source (read by build system)
- semantic-release updates version.txt on releases
- Zig doesn't mandate a specific version location, so we use version.txt for consistency

### CI/CD Secrets

Configure secrets once at the organization level (Settings → Secrets → Actions). All repositories inherit organization secrets automatically.

For GCP (default):
- `GCP_SA_KEY` - Service account JSON key
- `GCP_REGISTRY_PROJECT_ID`, `GCP_REGISTRY_REGION`, `GCP_REGISTRY_NAME` - Registry configuration

For other registries (see [user-guide.md](user-guide.md#cicd-secrets) for details):
- npm: `NPM_TOKEN`
- PyPI: `PYPI_TOKEN`
- Docker Hub: `DOCKER_USERNAME`, `DOCKER_PASSWORD`

See comments in `.github/workflows/release.yml` for additional registry options (AWS ECR, Azure ACR).

### Cross-Platform Support

The template works on macOS, Linux, and Windows (via WSL) without requiring users to install platform-specific tools. This broad compatibility reduces team onboarding friction and prevents "works on my machine" issues.

Key compatibility measures:
- Line endings enforced to LF via `.editorconfig` (prevents git diff noise on Windows)
- `sed_inplace` helper handles differences between macOS and GNU sed (abstracts platform quirks)
- Bash 3.2+ required (macOS ships with Bash 3.2, avoiding Bash 4+ features ensures compatibility without upgrades)
- Package manager detection for Homebrew (macOS), apt/yum/pacman (Linux), with fallback to curl (installs tools automatically based on available package managers)

### Security

Secrets belong in GitHub Secrets, never in `.envrc` or committed code, following the principle of separating configuration from credentials. The `.gitignore` includes comprehensive patterns for keys, certificates, credentials, and .env files to prevent accidental commits.

All scripts use `set -euo pipefail` for fail-fast behavior, ensuring errors don't silently propagate. Error traps handle cleanup on failure, preventing partial state. Lock files prevent concurrent script execution, avoiding race conditions during critical operations like scaffolding or version bumping.

### Testing

For Zig projects scaffolded from this template:

Zig tests live inline with source code:
```zig
// src/stringutils.zig
pub fn reverse(s: []const u8) []u8 {
    // implementation
}

test "reverse" {
    const result = reverse("hello");
    try std.testing.expectEqualStrings("olleh", result);
}
```

Run tests:
```bash
just test              # Runs: zig build test --summary all
```

For template development (maintaining this template itself), use bats-core for bash script testing:
```bash
just setup --template  # Install bats
just test-template     # Run template tests
```

Template tests cover scaffold.sh validation, .envrc handling, case variant replacements, and template file cleanup.

## References

Zig Resources:
- [Zig Language](https://ziglang.org/)
- [Zig Build System](https://ziglang.org/learn/build-system/)
- [Zig Package Manager](https://github.com/ziglang/zig/wiki/Package-Manager)
- [Zig Standard Library](https://ziglang.org/documentation/master/std/)
- [ZLS (Zig Language Server)](https://github.com/zigtools/zls)

Development Tools:
- [just command runner](https://github.com/casey/just)
- [direnv environment management](https://direnv.net/)
- [semantic-release](https://semantic-release.gitbook.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)

Infrastructure:
- [GitHub Actions](https://docs.github.com/en/actions)
- [GCP Artifact Registry](https://cloud.google.com/artifact-registry/docs)
- [bats-core bash testing](https://bats-core.readthedocs.io/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
