# Development Guide

`{{PROJECT_NAME}}` is a Zig project scaffolded from [{{TEMPLATE_NAME}}](https://github.com/cloudvoyant/nv-ziglib-template) (v{{TEMPLATE_VERSION}}), providing production-ready automation with versioning, multi-platform binary distribution, and GitHub Actions CI/CD. Build CLI tools or libraries with cross-compilation support for Linux, macOS, and Windows.

## Features

Zig-Specific:
- Zig 0.15.1 with automatic dependency fetching via build.zig.zon
- Multi-platform binary builds: Linux (x86_64, aarch64), macOS (x86_64, aarch64), Windows (x86_64)
- Code formatting with `zig fmt` integrated into CI
- Example library with comprehensive tests demonstrating Zig patterns
- Dual-use: build CLI tools (with install script) or libraries (via build.zig.zon)

Development Experience:
- Self-documenting command interface via `just` - all build/test/release commands in one place
- Auto-load environment with `direnv` for seamless shell integration
- Dev Containers with Zig + ZLS (language server) pre-configured
- Docker support for building without local Zig installation
- Hot reload workflow: `just run` rebuilds and runs on save

CI/CD & Publishing:
- Automated versioning with conventional commits (semantic-release)
- Multi-platform binaries published to GitHub Releases
- Optional GCP Artifact Registry publishing for enterprise distribution
- Tests run on every PR, releases on merge to main

## Requirements

- bash 3.2+
- Zig 0.15.1
- [just](https://just.systems/man/en/) (command runner)

Run `just setup` to install all dependencies automatically (Zig, just, direnv).

Optional: `just setup --dev` for development tools.

## Getting Started

## Quick Start

After scaffolding your project, setup and build:

```bash
just setup              # Install Zig 0.15.1, just, direnv
just build              # Build with Zig
just test               # Run Zig tests
just run                # Run your application
```

View all available commands:

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
    format               # Format Zig code
    lint                 # Lint Zig code

[ OUTPUT TRUNCATED ]
```

Example build and test:

```bash
❯ just build
Building {{PROJECT_NAME}}@1.0.0
Build Summary: 3/3 steps succeeded
└─ install
   └─ install {{PROJECT_NAME}}

❯ just test
Running tests

Build Summary: 3/3 steps succeeded; 7/7 tests passed
test success
+- run test 7 passed 1ms MaxRSS:1M
   +- compile test Debug native cached 45ms MaxRSS:30M
```

Commit using conventional commits to trigger automated releases:

```bash
git commit -m "feat: add new string utility"
git push origin main
# CI automatically: runs tests → creates release → publishes binaries
```

### Using Docker

The project includes Docker support for running tasks in isolated containers without installing Zig or other dependencies on your host machine.

Prerequisites:

- Docker Desktop or Docker Engine

Available Docker commands:

```bash
just docker-build    # Build the Docker image (installs Zig 0.15.1, just, direnv)
just docker-run      # Run the Zig binary in a container
just docker-test     # Run Zig tests in a container
```

The `Dockerfile` and `docker-compose.yml` are configured to install all required dependencies automatically, including:

- Zig 0.15.1 (installed via setup.sh)
- just (command runner)
- direnv (environment management)
- All build dependencies

This is useful for:

- Running Zig builds without installing Zig locally
- Ensuring consistency across different development machines
- Testing in a clean Linux environment (Ubuntu 22.04)

### Using Dev Containers

The project includes a pre-configured devcontainer for consistent cross-platform Zig development environments across your team.

Prerequisites on host:

- Docker Desktop or Docker Engine
- VS Code with Dev Containers extension

If you have Docker running and the Dev Container extension installed, then you can simply:

1. Open project in VS Code
2. Command Palette (Cmd/Ctrl+Shift+P) → "Dev Containers: Reopen in Container"
3. Wait for container build (first time only, includes Zig installation)

VS Code should reopen with full Zig development support:

Zig Development:
- Zig 0.15.1 pre-installed
- ZLS (Zig Language Server) automatically installed by the Zig extension
- Syntax highlighting, autocomplete, and go-to-definition
- Inline error checking and formatting

Shell & Infrastructure:
- `just`, `direnv`, Git, GitHub CLI, and Google Cloud CLI pre-installed
- Git credentials automatically shared from host via SSH agent forwarding
- Claude CLI credentials mounted from `~/.claude`
- All VS Code extensions (Zig, shellcheck, just syntax, Docker, etc.)
- Docker-in-Docker support for building containers

Authentication:
- Git/GitHub: Automatic via SSH agent forwarding (no setup needed)
- gcloud: Run `gcloud auth login` inside the container on first use
- Claude: Automatically available if configured on host

## The Basics

### Daily Commands

```bash
just install    # Fetch Zig dependencies (from build.zig.zon)
just build      # Build with Zig (debug mode)
just test       # Run Zig tests
just run        # Build and run your application
just clean      # Clean .zig-cache/ and zig-out/
just format     # Format Zig code with zig fmt
just lint       # Lint code (alias for build - checks compilation)
just lint-fix   # Auto-fix formatting (alias for format)
```

## Installation & Usage

This project supports two use cases:

1. **As a CLI Tool**: End users install pre-built binaries
2. **As a Library**: Zig projects import as a dependency

### Installing as a CLI Tool

#### Option 1: Quick Install (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_ORG/{{PROJECT_NAME}}/main/install.sh | bash
```

This script:
- Detects your OS and architecture
- Downloads the appropriate binary from GitHub Releases
- Installs to `~/.local/bin` or `/usr/local/bin`
- Verifies installation

#### Option 2: Manual Installation

1. Download the binary for your platform from [GitHub Releases](https://github.com/YOUR_ORG/{{PROJECT_NAME}}/releases):
   - `{{PROJECT_NAME}}-linux-x86_64`
   - `{{PROJECT_NAME}}-linux-aarch64`
   - `{{PROJECT_NAME}}-macos-x86_64`
   - `{{PROJECT_NAME}}-macos-aarch64`
   - `{{PROJECT_NAME}}-windows-x86_64.exe`

2. Extract and add to PATH:
   ```bash
   # Linux/macOS
   tar -xzf {{PROJECT_NAME}}-*.tar.gz
   mv {{PROJECT_NAME}}-* ~/.local/bin/{{PROJECT_NAME}}
   chmod +x ~/.local/bin/{{PROJECT_NAME}}

   # Add to PATH if needed
   echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

#### Option 3: Build from Source

```bash
git clone https://github.com/YOUR_ORG/{{PROJECT_NAME}}.git
cd {{PROJECT_NAME}}
zig build -Doptimize=ReleaseFast
sudo cp zig-out/bin/{{PROJECT_NAME}} /usr/local/bin/
```

### Using as a Library (Zig Projects)

#### Step 1: Add the dependency

Use `zig fetch` to automatically add this package to your `build.zig.zon`:

```bash
# Use a specific version (recommended for production)
zig fetch --save "git+https://github.com/YOUR_ORG/{{PROJECT_NAME}}#v1.0.0"

# Or track the latest changes on main
zig fetch --save "git+https://github.com/YOUR_ORG/{{PROJECT_NAME}}#main"
```

This automatically updates `build.zig.zon` with the correct hash.

#### Step 2: Configure your build

In your `build.zig`:

```zig
const {{PROJECT_NAME}} = b.dependency("{{PROJECT_NAME}}", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("{{PROJECT_NAME}}", {{PROJECT_NAME}}.module("{{PROJECT_NAME}}"));
```

In your source code:

```zig
const stringutils = @import("{{PROJECT_NAME}}");

pub fn main() void {
    const reversed = stringutils.reverse("Hello");
    // Use the library functions...
}
```

### Commit and Release

Use conventional commits for automatic versioning:

```bash
git commit -m "feat: add new feature"      # Minor bump (0.1.0 → 0.2.0)
git commit -m "fix: resolve bug"           # Patch bump (0.1.0 → 0.1.1)
git commit -m "docs: update readme"        # No bump
git commit -m "feat!: breaking change"     # Major bump (0.1.0 → 1.0.0)
```

Push to main:

```bash
git push origin main
```

CI/CD automatically runs tests, creates a release, and publishes to your configured registry.

### Viewing Hidden Files (VS Code)

The project provides `just hide` and `just show` commands to toggle file visibility in VS Code, helping you focus on code or see the full project structure as needed.

Hide non-essential files (show only code and documentation):

```bash
just hide
```

This hides infrastructure files and shows only: `docs/`, `src/`, `test/`, `.claude/`, `.envrc`, `justfile`, and `README.md`.

Show all files:

```bash
just show
```

This reveals all hidden configuration files (`.github/`, `.vscode/`, `.devcontainer/`, `Dockerfile`, `docker-compose.yml`, `scripts/`, etc.).

Note: These commands are VS Code-specific and modify `.vscode/settings.json`. If you use a different editor, you'll need to configure file visibility using your editor's native settings.

Limitation: Hidden files won't appear in VS Code search results (Cmd+Shift+F) unless you run `just show` first or toggle "Use Exclude Settings" in the search panel.

## Working with Zig

### Zig Build System (build.zig)

The project uses Zig's native build system. Key concepts:

build.zig defines your build configuration:
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create library
    const lib = b.addStaticLibrary(.{
        .name = "{{PROJECT_NAME}}",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create executable
    const exe = b.addExecutable(.{
        .name = "{{PROJECT_NAME}}",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
}
```

Build options:
- `zig build` - Debug build (default)
- `zig build -Doptimize=ReleaseFast` - Optimized for speed
- `zig build -Doptimize=ReleaseSafe` - Optimized with safety checks
- `zig build -Dtarget=x86_64-linux` - Cross-compile for specific target

### Dependency Management (build.zig.zon)

Add dependencies using `zig fetch --save` with git URLs:

```bash
# Use a specific version (recommended for production)
zig fetch --save "git+https://github.com/user/repo#v1.0.0"

# Or track a branch (main, master, develop, etc.)
zig fetch --save "git+https://github.com/user/repo#main"
```

This automatically updates `build.zig.zon` with the correct hash.

Then use in your `build.zig`:

```zig
const some_package = b.dependency("some_package", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("some_package", some_package.module("some_package"));
```

### Code Formatting

The project integrates `zig fmt` for automatic code formatting:

```bash
just format              # Format all Zig code
just format-check        # Check formatting (CI mode)
```

Zig has an official style enforced by `zig fmt`. No configuration needed.

### Linting

Zig doesn't have a separate linter - compilation itself serves as the linting step:

```bash
just lint                # Check compilation (alias for 'just build')
just lint-fix            # Auto-fix formatting (alias for 'just format')
```

In Zig:
- Linting = compilation with warnings/errors (`zig build`)
- Formatting = code style enforcement (`zig fmt`)
- Lint-fix = auto-format code (same as `just format`)

Since Zig's compiler catches most issues during compilation, there's no need for a separate linting tool like ESLint or pylint. The `lint-fix` command only fixes formatting issues - compilation errors must be fixed manually.

### Testing

Tests live inline with your source code:

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
just test                # Run all tests
zig build test           # Direct Zig command
```

### Project Structure

This is a dual-use project (library + CLI):

```
src/
├── lib.zig    # Library module (exports public API functions)
└── main.zig   # CLI executable entry point
```

Key files:
- `src/lib.zig` - Library module that other Zig projects can import
- `src/main.zig` - Command-line tool that uses the library
- `build.zig` - Build configuration (defines both library and executable)
- `build.zig.zon` - Package manifest with dependencies

How it works:
- The `lib.zig` module exports public functions (e.g., `startsWith`, `endsWith`)
- The `main.zig` executable imports and uses the library
- External projects can import just the library via `build.zig.zon`
- End users can install the CLI binary from GitHub Releases

### CI/CD Secrets

Configure secrets once at the organization level (Settings → Secrets → Actions):

For GitHub Releases (Default - Always Active):

No configuration needed! Binaries are automatically published to GitHub Releases using the GITHUB_TOKEN.

For GCP Artifact Registry (Optional - Enterprise/Internal Distribution):

Publishing to GCP is conditional - it only runs if GCP credentials are configured:

- `GCP_SA_KEY` - Service account JSON key with Artifact Registry Writer role
- `GCP_REGISTRY_PROJECT_ID` - Your GCP project ID
- `GCP_REGISTRY_REGION` - Registry region (e.g., `us-central1`)
- `GCP_REGISTRY_NAME` - Artifact Registry repository name

Setting up GCP publishing:

1. Create a service account with Artifact Registry Writer role:
   ```bash
   gcloud iam service-accounts create artifact-publisher \
     --display-name="Artifact Registry Publisher"

   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="serviceAccount:artifact-publisher@PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/artifactregistry.writer"
   ```

2. Create and download JSON key:
   ```bash
   gcloud iam service-accounts keys create key.json \
     --iam-account=artifact-publisher@PROJECT_ID.iam.gserviceaccount.com
   ```

3. Add secrets to GitHub repository (Settings → Secrets → Actions):
   - `GCP_SA_KEY`: Contents of `key.json`
   - `GCP_REGISTRY_PROJECT_ID`: Your project ID
   - `GCP_REGISTRY_REGION`: e.g., `us-central1`
   - `GCP_REGISTRY_NAME`: Your repository name

4. On next release, binaries will be published to both GitHub Releases and GCP Artifact Registry

For other registries:

- npm: `NPM_TOKEN`
- PyPI: `PYPI_TOKEN`
- Docker Hub: `DOCKER_USERNAME`, `DOCKER_PASSWORD`

All projects automatically inherit organization secrets.

## Overriding CI/CD

### Customizing Behavior

You can customize CI/CD behavior in three places:

1. `justfile` - Modify build, test, lint, format commands that CI uses
2. `scripts/` - Modify versioning and setup hooks
3. `.releaserc.json` - Configure semantic-release plugins

Customization points:

- `justfile` - Change how `just build`, `just test`, `just lint`, etc. work
- `scripts/upversion.sh` - Modify versioning logic
- `scripts/setup.sh` - Add custom dependencies
- `.releaserc.json` - Configure semantic-release plugins

Avoid editing `.github/workflows/` directly - modify the files above instead.

### Example: Custom Build Steps

The CI workflow runs `just build`. To add custom build steps, modify the `build` recipe in `justfile`:

```just
build:
    @echo "Running custom pre-build checks..."
    @./scripts/validate.sh
    @echo "Building with Zig..."
    @zig build
```

### Example: Custom Versioning

To change how versions are calculated, edit `scripts/upversion.sh` or modify `.releaserc.json` to add semantic-release plugins.

### Example: Additional Setup Steps

To add custom dependencies during CI setup, extend `scripts/setup.sh` with your logic.

## LLM Assistance with Claude

Claude commands provide guided workflows for complex tasks.

### Available Commands

```bash
claude /plan new                # Create a new project plan
claude /plan go                 # Execute the plan with spec-driven development
claude /plan pause              # Capture insights for resuming work later
claude /plan refresh            # Update plan status
claude /adr-new                 # Create architectural decision record
claude /adr-capture             # Capture decisions from conversation
claude /docs                    # Validate documentation
```

## Troubleshooting

### direnv not loading .envrc

Add to your shell config (~/.bashrc, ~/.zshrc):

```bash
eval "$(direnv hook bash)"  # or zsh, fish
```

Reload and allow:

```bash
source ~/.bashrc
direnv allow
```

### just command not found

Install just:

```bash
brew install just           # macOS
# Or run: bash scripts/setup.sh
```

### Tests pass locally but fail in CI

Check that:

- Runtime versions match CI (Node.js, Python, Go versions)
- Lock files are committed (package-lock.json, requirements.txt)
- All dependencies are declared

### Publish fails with authentication error

Verify GitHub organization secrets are configured:

1. Organization → Settings → Secrets → Actions
2. Check secrets exist (GCP_SA_KEY, NPM_TOKEN, etc.)
3. Ensure repository access is enabled

For GCP, verify service account has `roles/artifactregistry.writer` permission.

### semantic-release fails

Ensure:

- Default branch is named `main` (or update `.releaserc.json`)
- At least one commit uses conventional format
- GITHUB_TOKEN secret is accessible

## Next Steps

1. Customize `justfile` for your language
2. Write code in `src/`
3. Add tests
4. Configure GitHub organization secrets
5. Set up branch protection on `main`
6. Make your first conventional commit
7. Push and watch the automated release

See [Infrastructure](infrastructure.md) for implementation details.
