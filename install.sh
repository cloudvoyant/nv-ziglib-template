#!/usr/bin/env bash
# Install script for nv-ziglib-template
# Usage: curl -sSL https://raw.githubusercontent.com/USER/REPO/main/install.sh | bash

set -euo pipefail

# Configuration
REPO="USER/REPO"  # Will be replaced during scaffolding
BINARY_NAME="nv-ziglib-template"  # Will be replaced during scaffolding

# Detect OS and architecture
detect_platform() {
    local os=""
    local arch=""

    case "$(uname -s)" in
        Linux*)     os="linux" ;;
        Darwin*)    os="macos" ;;
        CYGWIN*|MINGW*|MSYS*) os="windows" ;;
        *)
            echo "Error: Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64)   arch="x86_64" ;;
        aarch64|arm64)  arch="aarch64" ;;
        *)
            echo "Error: Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac

    echo "${os}-${arch}"
}

# Get latest release version from GitHub
get_latest_version() {
    curl -sSL "https://api.github.com/repos/${REPO}/releases/latest" \
        | grep '"tag_name":' \
        | sed -E 's/.*"v?([^"]+)".*/\1/' \
        | head -n 1
}

# Determine installation directory
get_install_dir() {
    if [ -w "/usr/local/bin" ]; then
        echo "/usr/local/bin"
    elif [ -d "$HOME/.local/bin" ]; then
        echo "$HOME/.local/bin"
    else
        echo "$HOME/bin"
    fi
}

# Main installation
main() {
    echo "Installing ${BINARY_NAME}..."

    # Detect platform
    local platform=$(detect_platform)
    echo "Detected platform: ${platform}"

    # Get latest version
    local version=$(get_latest_version)
    if [ -z "$version" ]; then
        echo "Error: Could not determine latest version"
        exit 1
    fi
    echo "Latest version: v${version}"

    # Determine binary name with extension
    local binary_file="${BINARY_NAME}-${platform}"
    if [[ "$platform" == *"windows"* ]]; then
        binary_file="${binary_file}.exe"
    fi

    # Download URL
    local download_url="https://github.com/${REPO}/releases/download/v${version}/${binary_file}"
    echo "Downloading from: ${download_url}"

    # Determine install directory
    local install_dir=$(get_install_dir)
    echo "Installing to: ${install_dir}/${BINARY_NAME}"

    # Create install directory if it doesn't exist
    mkdir -p "${install_dir}"

    # Download and install
    if command -v curl >/dev/null 2>&1; then
        curl -sSL "${download_url}" -o "${install_dir}/${BINARY_NAME}"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "${download_url}" -O "${install_dir}/${BINARY_NAME}"
    else
        echo "Error: curl or wget is required"
        exit 1
    fi

    # Make executable
    chmod +x "${install_dir}/${BINARY_NAME}"

    echo "✓ ${BINARY_NAME} installed successfully!"
    echo ""

    # Check if install dir is in PATH
    if [[ ":$PATH:" != *":${install_dir}:"* ]]; then
        echo "Note: ${install_dir} is not in your PATH."
        echo "Add it by running:"
        echo "  echo 'export PATH=\"\$PATH:${install_dir}\"' >> ~/.bashrc"
        echo "  source ~/.bashrc"
        echo ""
    fi

    echo "Run '${BINARY_NAME} --help' to get started."
}

main
