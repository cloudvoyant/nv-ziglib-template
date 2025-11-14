#!/usr/bin/env bash
: <<DOCUMENTATION
Scaffolds a new project from this platform

Called by Nedavellir CLI after copying platform files to destination.
Updates project-specific configuration in the destination directory.

Usage:
  bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project
  bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project --non-interactive
  bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project --project myapp
  bash scripts/scaffold.sh  # Uses current directory for both src and dest

Options:
  --src PATH           Path to template source directory (default: project root)
  --dest PATH          Path to destination project directory (default: project root)
  --non-interactive    Skip prompts, use defaults
  --project NAME       Project name (default: destination directory name)
  --keep-claude        Keep .claude/ directory for AI workflows
DOCUMENTATION

# IMPORTS ----------------------------------------------------------------------
source "$(dirname "$0")/utils.sh"
set -euo pipefail

# Unset PROJECT and VERSION to force fresh read from .envrc
unset PROJECT VERSION

# Source .envrc to get PROJECT and VERSION
if [ -f ".envrc" ]; then
    source ".envrc"
fi

# CONFIGURATION ----------------------------------------------------------------
# Platform name will be read from source .envrc PROJECT variable

# Track if we've started making changes (for cleanup on error)
SCAFFOLD_STARTED=false
BACKUP_DIR=""

# Cleanup function for failed scaffolds
cleanup_on_error() {
    local exit_code=$?
    if [ "$exit_code" -ne 0 ] && [ "$SCAFFOLD_STARTED" = true ]; then
        log_error "Scaffolding failed. Restoring original directory..."

        if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
            # Ensure destination and all contents are writable for cleanup
            chmod u+w "$DEST_DIR" 2>/dev/null || true
            chmod -R u+w "$DEST_DIR" 2>/dev/null || true

            # Remove all files from destination (except .nv backup)
            find "$DEST_DIR" -mindepth 1 -maxdepth 1 ! -name '.nv' -exec rm -rf {} + 2>/dev/null || true

            # Restore entire directory from backup
            rsync -a "$BACKUP_DIR/" "$DEST_DIR/"

            # Remove backup
            rm -rf "$BACKUP_DIR"
        fi

        log_error "Destination directory has been restored to its original state"
    fi
}

trap cleanup_on_error EXIT

# PARSE OPTIONS ----------------------------------------------------------------
NON_INTERACTIVE=false
KEEP_CLAUDE=false
PROJECT_NAME=""

# Default to project root directory
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$PROJECT_ROOT"
DEST_DIR="$PROJECT_ROOT"

while [[ $# -gt 0 ]]; do
    case $1 in
        --src)
            SRC_DIR="$2"
            shift 2
            ;;
        --dest)
            DEST_DIR="$2"
            shift 2
            ;;
        --non-interactive)
            NON_INTERACTIVE=true
            shift
            ;;
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --keep-claude)
            KEEP_CLAUDE=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# VALIDATION -------------------------------------------------------------------
# Convert to absolute paths
SRC_DIR=$(cd "$SRC_DIR" 2>/dev/null && pwd) || {
    log_error "Source directory does not exist: $SRC_DIR"
    exit 1
}

DEST_DIR=$(cd "$DEST_DIR" 2>/dev/null && pwd) || {
    log_error "Destination directory does not exist: $DEST_DIR"
    exit 1
}

validate_project_name() {
    local name=$1
    # Allow alphanumeric, hyphens, underscores
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 1
    fi
    return 0
}

# Convert string to word array (split on _ - or camelCase boundaries)
string_to_words() {
    local input=$1
    # First, insert underscores before capital letters (for camelCase/PascalCase)
    input=$(echo "$input" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//')
    # Replace hyphens with underscores
    input=$(echo "$input" | tr '-' '_')
    # Convert to lowercase and split on underscores, output one word per line
    echo "$input" | tr '[:upper:]' '[:lower:]' | tr '_' '\n' | grep -v '^$'
}

# Convert word array to snake_case
words_to_snake() {
    echo "$1" | tr '\n' '_' | sed 's/_$//'
}

# Convert word array to kebab-case
words_to_kebab() {
    echo "$1" | tr '\n' '-' | sed 's/-$//'
}

# Convert word array to PascalCase
words_to_pascal() {
    echo "$1" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | tr -d '\n'
}

# Convert word array to camelCase
words_to_camel() {
    local words="$1"
    local first=$(echo "$words" | head -1)
    local rest=$(echo "$words" | tail -n +2)
    if [ -n "$rest" ]; then
        echo -n "$first"
        echo "$rest" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | tr -d '\n'
    else
        echo -n "$first"
    fi
}

# Convert word array to flatcase (no separators)
words_to_flat() {
    echo "$1" | tr -d '\n'
}

# DEFAULT PROJECT NAME ---------------------------------------------------------
DEFAULT_PROJECT=$(basename "$DEST_DIR")

# GET TEMPLATE NAME AND VERSION -----------------------------------------------
log_info "Detecting template name and version..."

# Use environment variables from sourced .envrc
TEMPLATE_NAME="$PROJECT"
TEMPLATE_VERSION="$VERSION"

# Validate we have the required values
if [ -z "$TEMPLATE_NAME" ]; then
    log_error "Could not determine template name (PROJECT not set)"
    exit 1
fi

if [ -z "$TEMPLATE_VERSION" ]; then
    log_error "Could not determine template version (VERSION not set)"
    exit 1
fi

log_success "Template: $TEMPLATE_NAME v$TEMPLATE_VERSION"

# INTERACTIVE PROMPTS ----------------------------------------------------------
if [ "$NON_INTERACTIVE" = false ]; then
    log_info "Scaffolding new project from $TEMPLATE_NAME platform"
    echo ""

    # Prompt for project name
    while true; do
        read -p "Project name [$DEFAULT_PROJECT]: " input_name
        PROJECT_NAME="${input_name:-$DEFAULT_PROJECT}"

        if validate_project_name "$PROJECT_NAME"; then
            break
        else
            log_error "Invalid project name. Use only letters, numbers, hyphens, and underscores."
        fi
    done

    # Prompt for GCP registry configuration
    read -p "Configure GCP Artifact Registry? (y/N): " configure_gcp
    if [[ "$configure_gcp" =~ ^[Yy]$ ]]; then
        read -p "GCP Project ID: " gcp_project_id
        read -p "GCP Region [us-east1]: " gcp_region
        gcp_region="${gcp_region:-us-east1}"
        read -p "GCP Repository: " gcp_repository
        CONFIGURE_GCP=true
    else
        CONFIGURE_GCP=false
    fi

    # Prompt for .claude/ directory
    read -p "Keep .claude/ directory for AI workflows? (y/N): " keep_claude_input
    if [[ "$keep_claude_input" =~ ^[Yy]$ ]]; then
        KEEP_CLAUDE=true
    fi

    echo ""
else
    # Non-interactive mode: use defaults
    PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_PROJECT}"
    CONFIGURE_GCP=false

    if ! validate_project_name "$PROJECT_NAME"; then
        log_error "Invalid project name: $PROJECT_NAME"
        exit 1
    fi

    log_info "Non-interactive mode: project=$PROJECT_NAME"
fi

# BACKUP DESTINATION DIRECTORY ------------------------------------------------
log_info "Creating backup of destination directory..."

BACKUP_DIR="$DEST_DIR/.nv/.scaffold-backup"
mkdir -p "$BACKUP_DIR"

# Backup entire destination directory (excluding .nv to avoid recursion)
rsync -a \
    --exclude='.nv' \
    "$DEST_DIR/" "$BACKUP_DIR/"

# Mark that we've started making changes
SCAFFOLD_STARTED=true

log_success "Backup created"

# COPY PLATFORM FILES TO DESTINATION -------------------------------------------
log_info "Copying platform files to destination..."

# Copy all files from source to destination
# Exclude: .git, .nv, test/, docs/migrations/, docs/decisions/, CHANGELOG.md, RELEASE_NOTES.md
rsync -a \
    --exclude='.git' \
    --exclude='.nv' \
    --exclude='test/' \
    --exclude='docs/migrations/' \
    --exclude='docs/decisions/' \
    --exclude='CHANGELOG.md' \
    --exclude='RELEASE_NOTES.md' \
    "$SRC_DIR/" "$DEST_DIR/"

log_success "Platform files copied"

# REPLACE TEMPLATE NAME WITH PROJECT NAME IN ALL VARIANTS ---------------------
log_info "Replacing template name with project name..."

# Generate all variants of template name and project name
TEMPLATE_WORDS=$(string_to_words "$TEMPLATE_NAME")
PROJECT_WORDS=$(string_to_words "$PROJECT_NAME")

# Template name variants
TEMPLATE_SNAKE=$(words_to_snake "$TEMPLATE_WORDS")
TEMPLATE_KEBAB=$(words_to_kebab "$TEMPLATE_WORDS")
TEMPLATE_PASCAL=$(words_to_pascal "$TEMPLATE_WORDS")
TEMPLATE_CAMEL=$(words_to_camel "$TEMPLATE_WORDS")
TEMPLATE_FLAT=$(words_to_flat "$TEMPLATE_WORDS")

# Project name variants
PROJECT_SNAKE=$(words_to_snake "$PROJECT_WORDS")
PROJECT_KEBAB=$(words_to_kebab "$PROJECT_WORDS")
PROJECT_PASCAL=$(words_to_pascal "$PROJECT_WORDS")
PROJECT_CAMEL=$(words_to_camel "$PROJECT_WORDS")
PROJECT_FLAT=$(words_to_flat "$PROJECT_WORDS")

# Replace in all text files (excluding binary files, .git, and build artifacts)
find "$DEST_DIR" -type f \
    ! -path "*/.git/*" \
    ! -path "$DEST_DIR/.nv/*" \
    ! -path "*/.zig-cache/*" \
    ! -path "*/zig-cache/*" \
    ! -path "*/zig-out/*" \
    ! -path "*/node_modules/*" \
    2>/dev/null | while IFS= read -r file; do
    # Skip binary files (check for null bytes)
    if file "$file" | grep -q "text\|JSON\|empty"; then
        # Replace all variants (order matters: longer strings first to avoid partial replacements)
        sed_inplace "s/${TEMPLATE_PASCAL}/${PROJECT_PASCAL}/g" "$file" || true
        sed_inplace "s/${TEMPLATE_CAMEL}/${PROJECT_CAMEL}/g" "$file" || true
        sed_inplace "s/${TEMPLATE_SNAKE}/${PROJECT_SNAKE}/g" "$file" || true
        sed_inplace "s/${TEMPLATE_KEBAB}/${PROJECT_KEBAB}/g" "$file" || true
        sed_inplace "s/${TEMPLATE_FLAT}/${PROJECT_FLAT}/g" "$file" || true
    fi
done

log_success "Replaced template name with project name"

# UPDATE .ENVRC ----------------------------------------------------------------
log_info "Configuring .envrc..."

ENVRC_TEMPLATE="$SRC_DIR/.envrc.template"
ENVRC_FILE="$DEST_DIR/.envrc"

if [ ! -f "$ENVRC_TEMPLATE" ]; then
    log_error ".envrc.template not found in source directory"
    exit 1
fi

# Copy template to destination
cp "$ENVRC_TEMPLATE" "$ENVRC_FILE"

# Create version.txt with initial version
echo "0.1.0" > "$DEST_DIR/version.txt"

# Update build.zig.zon version to match and reset fingerprint
if [ -f "$DEST_DIR/build.zig.zon" ]; then
    sed_inplace 's/\.version = "[^"]*"/.version = "0.1.0"/' "$DEST_DIR/build.zig.zon"
    # Reset fingerprint - will be regenerated by zig build --fetch
    sed_inplace 's/\.fingerprint = .*/\.fingerprint = 0x0000000000000000,/' "$DEST_DIR/build.zig.zon"
fi

# Update PROJECT name
sed_inplace "s/__PROJECT_NAME__/$PROJECT_NAME/" "$ENVRC_FILE"

# Configure GCP if requested
if [ "$CONFIGURE_GCP" = true ]; then
    sed_inplace "s/export GCP_REGISTRY_PROJECT_ID=.*/export GCP_REGISTRY_PROJECT_ID=$gcp_project_id/" "$ENVRC_FILE"
    sed_inplace "s/export GCP_REGISTRY_REGION=.*/export GCP_REGISTRY_REGION=$gcp_region/" "$ENVRC_FILE"
    sed_inplace "s/export GCP_REGISTRY_NAME=.*/export GCP_REGISTRY_NAME=$gcp_repository/" "$ENVRC_FILE"
    log_success "GCP registry configured in .envrc"
fi

# Add template tracking variables after VERSION line
if ! grep -q "NV_TEMPLATE" "$ENVRC_FILE"; then
    # Find line with VERSION and add NV_TEMPLATE vars after it
    awk -v template="$TEMPLATE_NAME" -v version="$TEMPLATE_VERSION" '
    /^export VERSION=/ {
        print $0
        print ""
        print "# Nedavellir template tracking"
        print "export NV_TEMPLATE=" template
        print "export NV_TEMPLATE_VERSION=" version
        next
    }
    { print }
    ' "$ENVRC_FILE" > "$ENVRC_FILE.tmp" && mv "$ENVRC_FILE.tmp" "$ENVRC_FILE"
fi

log_success "Created and configured .envrc from template"

# UPDATE INSTALL.SH ------------------------------------------------------------
if [ -f "$DEST_DIR/install.sh" ]; then
    log_info "Configuring install.sh..."

    # Try to get GitHub repo from git remote (if initialized)
    if git -C "$DEST_DIR" rev-parse --git-dir > /dev/null 2>&1; then
        GITHUB_REPO=$(git -C "$DEST_DIR" remote get-url origin 2>/dev/null | sed -E 's#https://github.com/([^/]+/[^/]+)(\.git)?#\1#' || echo "")
    else
        GITHUB_REPO=""
    fi

    # If no git remote, prompt user or use placeholder
    if [ -z "$GITHUB_REPO" ]; then
        if [ "$NON_INTERACTIVE" = false ]; then
            read -r -p "GitHub repository (owner/repo) [leave empty to set later]: " GITHUB_REPO
        fi

        if [ -z "$GITHUB_REPO" ]; then
            GITHUB_REPO="YOUR_GITHUB_USER/YOUR_REPO"
            log_warn "install.sh configured with placeholder repo. Update REPO variable before publishing."
        fi
    fi

    # Replace REPO placeholder
    sed_inplace "s#REPO=\"USER/REPO\"#REPO=\"$GITHUB_REPO\"#" "$DEST_DIR/install.sh"

    # Replace BINARY_NAME placeholder with project name (kebab-case is standard for binaries)
    sed_inplace "s#BINARY_NAME=\"${TEMPLATE_KEBAB}\"#BINARY_NAME=\"${PROJECT_KEBAB}\"#" "$DEST_DIR/install.sh"

    log_success "Configured install.sh (repo: $GITHUB_REPO, binary: $PROJECT_KEBAB)"
fi

# CLEAN UP .CLAUDE/ DIRECTORY --------------------------------------------------
if [ "$KEEP_CLAUDE" = false ]; then
    log_info "Cleaning .claude/ directory..."

    # Remove instance-specific files
    rm -f "$DEST_DIR/.claude/plan.md"
    rm -f "$DEST_DIR/.claude/tasks.md"

    # Keep user-facing files:
    # - instructions.md, style.md, workflows.md
    # - commands: upgrade.md, adapt.md, docs.md, adr-new.md, adr-capture.md

    log_success "Removed template development files from .claude/"
else
    log_info "Keeping .claude/ directory"
fi

# CLEAN UP TEMPLATE FILES ------------------------------------------------------
log_info "Cleaning template files..."

# Remove template section from justfile
JUSTFILE="$DEST_DIR/justfile"
if [ -f "$JUSTFILE" ]; then
    # Remove everything from "# TEMPLATE" comment to end of file
    sed_inplace '/# TEMPLATE$/,$ {/# TEMPLATE$/d; d;}' "$JUSTFILE"
fi

# Remove --template flag from Dockerfile
DOCKERFILE="$DEST_DIR/Dockerfile"
if [ -f "$DOCKERFILE" ]; then
    # Remove --template flag from setup.sh calls
    sed_inplace 's/--template //g' "$DOCKERFILE"
    # Update comment to reflect the change
    sed_inplace 's/and template testing tools (bats-core), //' "$DOCKERFILE"
fi

# Replace README.md with template
if [ -f "$SRC_DIR/README.template.md" ]; then
    log_info "Creating README from template..."

    # Copy template and substitute variables
    sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g; \
         s/{{TEMPLATE_NAME}}/$TEMPLATE_NAME/g; \
         s/{{TEMPLATE_VERSION}}/$TEMPLATE_VERSION/g" \
        "$SRC_DIR/README.template.md" > "$DEST_DIR/README.md"

    log_success "Created README.md from template"
else
    log_warn "README.template.md not found, keeping original README.md"
fi

log_success "Removed template development files"

# REGENERATE ZIG FINGERPRINT ---------------------------------------------------
log_info "Regenerating Zig package fingerprint..."

if command -v zig >/dev/null 2>&1; then
    # Change to destination directory and run zig build --fetch
    (cd "$DEST_DIR" && zig build --fetch 2>&1) || {
        log_warn "Failed to regenerate fingerprint. Run 'just install' manually after scaffolding."
    }
    log_success "Zig package fingerprint regenerated"
else
    log_warn "Zig not found. Run 'just install' after scaffolding to regenerate fingerprint."
fi

# CLEANUP BACKUP ---------------------------------------------------------------
# Remove backup on success
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    rm -rf "$BACKUP_DIR"
fi

# SUMMARY ----------------------------------------------------------------------
echo ""
log_success "✓ Scaffolding complete!"
echo ""
echo "Project: $PROJECT_NAME"
echo "Template: $TEMPLATE_NAME v$TEMPLATE_VERSION"
echo ""
log_info "Next steps:"
echo "  1. Review .envrc for project configuration"
echo "  2. Edit justfile to implement build/test/publish recipes"
echo "  3. Add your source code to src/"
echo "  4. Configure GitHub organization secrets (see docs/user-guide.md)"
echo "  5. Initialize git and commit: git init && git add . && git commit -m 'Initial commit'"
echo ""

# Mark successful completion (prevents cleanup on exit)
SCAFFOLD_STARTED=false
