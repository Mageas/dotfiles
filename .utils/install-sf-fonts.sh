#!/usr/bin/env bash

set -euo pipefail

# Configuration
FONT_DIR="/tmp/San-Francisco-family"
SYSTEM_FONT_LOCATION="/usr/local/share/fonts/otf"
FONT_URL="https://github.com/thelioncape/San-Francisco-family.git"
FONTS=("SF Pro" "SF Serif" "SF Mono")

# Colors and styles
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Utility functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_section() {
    echo
    echo -e "${BOLD}${YELLOW}▶ $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

check_dependencies() {
    if ! command -v git &>/dev/null; then
        log_error "Git is not installed. Please install it first."
        exit 1
    fi
    log_success "Git found"
}

clone_repo() {
    print_section "Cloning repository"

    if [[ -d "$FONT_DIR" ]]; then
        log_info "Existing temporary folder found, removing..."
        rm -rf "$FONT_DIR"
    fi

    git clone -n --depth=1 --filter=tree:0 "$FONT_URL" "$FONT_DIR" &>/dev/null
    cd "$FONT_DIR" || exit 1

    log_info "Extracting fonts..."
    git sparse-checkout set --no-cone "${FONTS[@]}" &>/dev/null
    git checkout &>/dev/null

    log_success "Repository cloned to $FONT_DIR"
}

copy_files() {
    print_section "Installing fonts"

    log_info "Creating directories..."
    sudo mkdir -p "$SYSTEM_FONT_LOCATION"/sf-{pro,serif,mono}

    log_info "Copying .otf files..."
    sudo cp "$FONT_DIR/SF Pro"/*.otf "$SYSTEM_FONT_LOCATION/sf-pro/" 2>/dev/null || true
    sudo cp "$FONT_DIR/SF Serif"/*.otf "$SYSTEM_FONT_LOCATION/sf-serif/" 2>/dev/null || true
    sudo cp "$FONT_DIR/SF Mono"/*.otf "$SYSTEM_FONT_LOCATION/sf-mono/" 2>/dev/null || true

    log_success "Fonts installed to $SYSTEM_FONT_LOCATION"
}

cleanup() {
    if [[ -d "$FONT_DIR" ]]; then
        rm -rf "$FONT_DIR"
        log_info "Temporary folder cleaned up"
    fi
}

# Main execution
trap cleanup EXIT
check_dependencies
clone_repo
copy_files

print_section "Done!"
log_success "San Francisco fonts are now installed."
log_info "Run 'fc-cache -fv' to update the font cache."
