# nv-ziglib-template

![Version](https://img.shields.io/github/v/release/cloudvoyant/nv-ziglib-template?label=version)
![Release](https://github.com/cloudvoyant/nv-ziglib-template/workflows/Release/badge.svg)
![Zig](https://img.shields.io/badge/zig-0.15.1-orange)

A production-ready Zig project template with automated versioning, multi-platform binary distribution, and GitHub Actions CI/CD. Build libraries or CLI tools with cross-compilation support for Linux, macOS, and Windows.

## Features

### Zig-Specific Features

- Multi-platform binary builds: Automatically cross-compile for Linux (x86_64, aarch64), macOS (x86_64, aarch64), and Windows (x86_64)
- Dual-use template: Build CLI tools (with install script) or libraries (via build.zig.zon)
- Zig 0.15.1 with automatic dependency fetching via build.zig.zon
- Code formatting with `zig fmt` integrated into CI
- Example library with comprehensive tests demonstrating Zig patterns

### Development Experience

- Self-documenting command interface via `just` - all build/test/release commands in one place
- Auto-load environment with `direnv` for seamless shell integration
- Dev Containers with Zig + ZLS (language server) pre-configured
- Docker support for building without local Zig installation
- Hot reload workflow: `just run` rebuilds and runs on save

### CI/CD & Publishing

- Automated versioning with conventional commits (semantic-release)
- Multi-platform binaries published to GitHub Releases
- Optional GCP Artifact Registry publishing for enterprise distribution
- Install script for easy CLI tool installation: `curl -sSL https://raw.githubusercontent.com/cloudvoyant/nv-ziglib-template/main/install.sh | bash`
- Tests run on every PR, releases on merge to main

## Requirements

- bash 3.2+
- Zig 0.15.1
- just (command runner)

Run `just setup` to install all dependencies automatically (Zig, just, direnv).

Optional: `just setup --dev` for development tools, `just setup --template` for template testing.

## Quick Start

Create a new Zig project from this template:

```bash
# Option 1: Nedavellir CLI (automated)
nv create your-project-name --platform nv-ziglib-template

# Option 2: GitHub template + scaffold script
# Click "Use this template" on GitHub, then:
git clone <your-new-repo>
cd <your-new-repo>
bash scripts/scaffold.sh --project your-project-name
```

Setup and build your project:

```bash
just setup              # Install dependencies: Zig 0.15.1, just, direnv
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

Example build and test output:

```bash
❯ just build
Building nv-ziglib-template@1.1.0
Build Summary: 3/3 steps succeeded
└─ install
   └─ install nv-ziglib-template

❯ just test
Running tests

Build Summary: 3/3 steps succeeded; 7/7 tests passed
test success
+- run test 7 passed 1ms MaxRSS:1M
   +- compile test Debug native cached 45ms MaxRSS:30M
```

Commit using conventional commits and push to trigger automated releases:

```bash
git commit -m "feat: add new string utility"
git push origin main
# CI automatically: runs tests → creates release → publishes binaries
```

## Using This Template

This template is designed for Zig projects and supports two primary use cases:

### 1. CLI Tools
Build command-line applications with automatic multi-platform binary distribution.

Install pre-built binaries:
```bash
curl -sSL https://raw.githubusercontent.com/cloudvoyant/nv-ziglib-template/main/install.sh | bash
```

### 2. Libraries
Create reusable Zig libraries that other projects can import.

Add as a dependency to your Zig project:
```bash
# Use a specific version (recommended for production)
zig fetch --save "git+https://github.com/cloudvoyant/nv-ziglib-template#v1.1.0"

# Or track the latest changes on main
zig fetch --save "git+https://github.com/cloudvoyant/nv-ziglib-template#main"
```

Then in your `build.zig`:
```zig
const nv_ziglib_template = b.dependency("nv_ziglib_template", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("nv-ziglib-template", nv_ziglib_template.module("nv_ziglib_template"));
```

### After Scaffolding

Customize the example code in `src/` to build your:

- Command-line utilities with argument parsing
- Reusable libraries with well-tested APIs
- Mixed projects (library with CLI frontend)

The template handles versioning, testing, formatting, and multi-platform releases automatically. Just write Zig code and use conventional commits.

## Documentation

To learn more about using this template, read the docs:

- [User Guide](docs/user-guide.md) - Complete setup and usage guide
- [Architecture](docs/architecture.md) - Design and implementation details

## TODO

- [ ] Pre-release publishing support

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
