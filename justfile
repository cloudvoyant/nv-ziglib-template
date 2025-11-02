# justfile - Command runner for project automation
# Requires: just (https://github.com/casey/just)

set shell   := ["bash", "-c"]

# Dependencies
bash        := require("bash")
direnv      := require("direnv")

# Environment variables available for all scripts
export _PROJECT                 := `source .envrc && echo $PROJECT`
export VERSION                  := `source .envrc && echo $VERSION`
export GCP_REGISTRY_PROJECT_ID  := `source .envrc && echo $GCP_REGISTRY_PROJECT_ID`
export GCP_REGISTRY_REGION      := `source .envrc && echo $GCP_REGISTRY_REGION`
export GCP_REGISTRY_NAME        := `source .envrc && echo $GCP_REGISTRY_NAME`

# Color codes for output
INFO        := '\033[0;34m'
SUCCESS     := '\033[0;32m'
WARN        := '\033[1;33m'
ERROR       := '\033[0;31m'
NORMAL      := '\033[0m'

# ==============================================================================
# CORE DEVELOPMENT
# ==============================================================================

# Default recipe (show help)
_default:
    @just --list --unsorted

# Load environment
[group('dev')]
load:
    @direnv allow

# Install dependencies
[group('dev')]
install:
    @echo -e "{{INFO}}Fetching Zig dependencies from build.zig.zon...{{NORMAL}}"
    @zig build --fetch

# Build the project
[group('dev')]
build:
    @echo -e "{{INFO}}Building $_PROJECT@$VERSION...{{NORMAL}}"
    @zig build

# Run project locally
[group('dev')]
run: build
    @echo -e "{{INFO}}Running example...{{NORMAL}}"
    @zig build run

# Run tests
[group('dev')]
test:
    @echo -e "{{INFO}}Running tests...{{NORMAL}}"
    @zig build test --summary all

# Clean build artifacts
[group('dev')]
clean:
    @echo -e "{{INFO}}Cleaning build artifacts...{{NORMAL}}"
    @rm -rf .zig-cache/ zig-out/ .nv/
    @echo -e "{{SUCCESS}}Clean complete{{NORMAL}}"

# ==============================================================================
# DOCKER
# ==============================================================================

[group('docker')]
docker-build:
    @COMPOSE_BAKE=true docker compose build

[group('docker')]
docker-run:
    @docker compose run --rm runner

[group('docker')]
docker-test:
    @docker compose run --rm tester

# ==============================================================================
# UTILITIES
# ==============================================================================

# Setup development environment
[group('utils')]
setup *ARGS:
    @bash scripts/setup.sh {{ARGS}}

# Format code
[group('utils')]
format *PATHS:
    @echo -e "{{INFO}}Formatting Zig code...{{NORMAL}}"
    @zig fmt src/ build.zig {{PATHS}}
    @echo -e "{{SUCCESS}}Formatting complete{{NORMAL}}"

# Check code formatting (CI mode)
[group('utils')]
format-check *PATHS:
    @echo -e "{{INFO}}Checking Zig code formatting...{{NORMAL}}"
    @zig fmt --check src/ build.zig {{PATHS}}
    @echo -e "{{SUCCESS}}Format check passed{{NORMAL}}"

# Lint code
[group('utils')]
lint *PATHS:
    @echo -e "{{INFO}}Linting Zig code (building with full warnings)...{{NORMAL}}"
    @zig build
    @echo -e "{{SUCCESS}}Lint check passed{{NORMAL}}"

# Lint and auto-fix issues
[group('utils')]
lint-fix *PATHS:
    @echo -e "{{INFO}}Auto-fixing Zig code (formatting)...{{NORMAL}}"
    @zig fmt src/ build.zig {{PATHS}}
    @echo -e "{{SUCCESS}}Auto-fix complete{{NORMAL}}"

# Upgrade to newer template version (requires Claude Code)
[group('utils')]
upgrade:
    #!/usr/bin/env bash
    if command -v claude >/dev/null 2>&1; then
        if grep -q "NV_PLATFORM=" .envrc 2>/dev/null; then
            claude /upgrade;
        else
            echo -e "{{ERROR}}This project is not based on a template{{NORMAL}}";
            echo "";
            echo "To adopt a template, use the nv CLI:";
            echo "  nv scaffold <template>";
            exit 1;
        fi;
    else
        echo -e "{{ERROR}}Claude Code CLI not found{{NORMAL}}";
        echo "Install Claude Code or run: /upgrade";
        exit 1;
    fi

# Authenticate with GCP (local: gcloud login, CI: service account)
[group('utils')]
registry-login *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ " {{ARGS}} " =~ " --ci " ]]; then
        echo -e "{{INFO}}CI mode - authenticating with service account{{NORMAL}}"
        KEY_FILE=$(mktemp)
        echo "$GCP_SA_KEY" > "$KEY_FILE"
        gcloud auth activate-service-account --key-file="$KEY_FILE"
        rm -f "$KEY_FILE"
        gcloud config set project "$GCP_REGISTRY_PROJECT_ID"
    else
        echo -e "{{INFO}}Local mode - interactive GCP login{{NORMAL}}"
        gcloud auth login
        gcloud config set project "$GCP_REGISTRY_PROJECT_ID"
    fi

# ==============================================================================
# CI/CD
# ==============================================================================

# Build for production
[group('ci')]
build-prod:
    @echo -e "{{INFO}}Building production artifacts for $_PROJECT@$VERSION...{{NORMAL}}"
    @zig build -Doptimize=ReleaseFast
    @echo -e "{{SUCCESS}}Production build complete in zig-out/{{NORMAL}}"

# Run production binary
[group('ci')]
run-prod *ARGS: build-prod
    @echo -e "{{INFO}}Running production binary...{{NORMAL}}"
    @./zig-out/bin/$_PROJECT {{ARGS}}

# Get current version
[group('ci')]
version:
    @echo "$VERSION"

# Get next version (from semantic-release)
[group('ci')]
version-next:
    @bash -c 'source scripts/utils.sh && get_next_version'

# Create new version based on commits (semantic-release)
[group('ci')]
upversion *ARGS:
    @bash -c scripts/upversion.sh {{ARGS}}

# Publish the project
[group('ci')]
publish: test build-prod
    #!/usr/bin/env bash
    set -euo pipefail

    # Load environment variables
    if [ -f .envrc ]; then
        source .envrc
    fi

    echo -e "{{INFO}}Publishing package $PROJECT@$VERSION...{{NORMAL}}"

    # Create tarball of binaries for GCP Artifact Registry
    tar -czf $PROJECT-$VERSION.tar.gz -C zig-out .

    gcloud artifacts generic upload \
        --project=$GCP_REGISTRY_PROJECT_ID \
        --location=$GCP_REGISTRY_REGION \
        --repository=$GCP_REGISTRY_NAME \
        --package=$PROJECT \
        --version=$VERSION \
        --source=$PROJECT-$VERSION.tar.gz

    echo -e "{{SUCCESS}}Published $PROJECT@$VERSION{{NORMAL}}"

# ==============================================================================
# TEMPLATE
# ==============================================================================

# Scaffold a new project
[group('template')]
scaffold:
    @bash scripts/scaffold.sh

# Run template tests
[group('template')]
test-template:
    #!/usr/bin/env bash
    if command -v bats >/dev/null 2>&1; then
        echo -e "{{INFO}}Running template tests...{{NORMAL}}";
        bats test/;
    else
        echo -e "{{ERROR}}bats not installed. Run: just setup --template{{NORMAL}}";
        exit 1;
    fi

# ==============================================================================
# VS CODE
# ==============================================================================

# Hide non-essential files in VS Code
[group('vscode')]
hide:
    @bash scripts/toggle-files.sh hide

# Show all files in VS Code
[group('vscode')]
show:
    @bash scripts/toggle-files.sh show
