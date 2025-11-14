#!/usr/bin/env bash
: <<DOCUMENTATION
Toggle file visibility in VS Code by modifying .vscode/settings.json

Usage: toggle-files.sh [hide|show]

Commands:
  hide  - Hide non-essential files (show only: docs/, src/, test/, .envrc, justfile, README.md)
  show  - Show all files
DOCUMENTATION

set -euo pipefail

# IMPORTS ----------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source utils.sh if it exists, otherwise define minimal logging functions
if [ -f "$SCRIPT_DIR/utils.sh" ]; then
    source "$SCRIPT_DIR/utils.sh"
else
    # Minimal logging functions
    log_info() { echo "[INFO] $1"; }
    log_success() { echo "[SUCCESS] $1"; }
    log_error() { echo "[ERROR] $1" >&2; }
fi

# CONFIGURATION ----------------------------------------------------------------

SETTINGS_FILE="${SCRIPT_DIR}/../.vscode/settings.json"

# Files to hide when in "hide" mode (set to true)
HIDE_PATTERNS=(
    ".devcontainer"
    ".vscode"
    ".github"
    ".editorconfig"
    ".gitignore"
    ".gitattributes"
    ".releaserc.json"
    ".nv"
    ".zig-cache"
    ".dockerignore"
    "Dockerfile"
    "docker-compose.yml"
    "version.txt"
    "scripts"
    "CONTRIBUTING.md"
    "CHANGELOG.md"
)

# Files to keep visible even in "hide" mode (set to false)
SHOW_PATTERNS=(
    "justfile"
    "build.zig"
    "build.zig.zon"
    ".claude"
)

# FUNCTIONS --------------------------------------------------------------------

# Update files.exclude section in settings.json
update_file_exclusions() {
    local mode=$1

    if [ ! -f "$SETTINGS_FILE" ]; then
        log_error "Settings file not found: $SETTINGS_FILE"
        return 1
    fi

    # Create backup
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"

    if [ "$mode" = "hide" ]; then
        # Hide non-essential files using configured patterns
        # First, set files to hide to true
        for pattern in "${HIDE_PATTERNS[@]}"; do
            # Escape special regex characters for sed
            escaped_pattern=$(echo "$pattern" | sed 's/\./\\./g')
            sed -i.tmp "s/\"${escaped_pattern}\": [^,]*/\"${pattern}\": true/" "$SETTINGS_FILE"

            # Add pattern if it doesn't exist
            if ! grep -q "\"${pattern}\"" "$SETTINGS_FILE"; then
                sed -i.tmp "/\"files.exclude\": {/,/}/ s/\(.*\)}/    \"${pattern}\": true,\n\1}/" "$SETTINGS_FILE"
            fi
        done

        # Then, set files to keep visible to false
        for pattern in "${SHOW_PATTERNS[@]}"; do
            # Escape special regex characters for sed
            escaped_pattern=$(echo "$pattern" | sed 's/\./\\./g')
            sed -i.tmp "s/\"${escaped_pattern}\": [^,]*/\"${pattern}\": false/" "$SETTINGS_FILE"

            # Add pattern if it doesn't exist
            if ! grep -q "\"${pattern}\"" "$SETTINGS_FILE"; then
                sed -i.tmp "/\"files.exclude\": {/,/}/ s/\(.*\)}/    \"${pattern}\": false,\n\1}/" "$SETTINGS_FILE"
            fi
        done
    else
        # Show all files - set everything to false
        for pattern in "${HIDE_PATTERNS[@]}" "${SHOW_PATTERNS[@]}"; do
            # Escape special regex characters for sed
            escaped_pattern=$(echo "$pattern" | sed 's/\./\\./g')
            sed -i.tmp "s/\"${escaped_pattern}\": [^,]*/\"${pattern}\": false/" "$SETTINGS_FILE"
        done
    fi

    # Remove temp file
    rm -f "${SETTINGS_FILE}.tmp"

    # Verify the file is still valid (basic check)
    if [ -f "$SETTINGS_FILE" ]; then
        rm -f "${SETTINGS_FILE}.bak"
        return 0
    else
        # Restore backup on failure
        mv "${SETTINGS_FILE}.bak" "$SETTINGS_FILE"
        return 1
    fi
}

# MAIN -------------------------------------------------------------------------

MODE="${1:-}"

if [ -z "$MODE" ]; then
    log_error "Usage: toggle-files.sh [hide|show]"
    exit 1
fi

case "$MODE" in
    hide)
        log_info "Hiding non-essential files in VS Code..."
        if update_file_exclusions "hide"; then
            log_success "VS Code: Files hidden successfully"
            log_info "VS Code visible: docs/, src/, test/, .claude/, .envrc, justfile, build.zig, build.zig.zon, README.md"
        else
            log_error "Failed to update VS Code settings"
            exit 1
        fi
        ;;
    show)
        log_info "Showing all files in VS Code..."
        if update_file_exclusions "show"; then
            log_success "VS Code: All files are now visible"
        else
            log_error "Failed to update VS Code settings"
            exit 1
        fi
        ;;
    *)
        log_error "Invalid mode: $MODE"
        log_error "Usage: toggle-files.sh [hide|show]"
        exit 1
        ;;
esac
