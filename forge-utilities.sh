#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Helpers
info()    { echo -e "${CYAN}${BOLD} :: ${NC}$*"; }
skip()    { echo -e "${DIM} →  $*${NC}"; }
success() { echo -e "${GREEN}${BOLD}  ✔  ${NC}$*"; }
warning() { echo -e "${YELLOW}${BOLD}  ⚠  ${NC}  $*"; }
error()   { echo -e "${RED}${BOLD}  ✘${NC}  $*" >&2; }
section() { echo -e "\n${BLUE}${BOLD}▶ $*${NC}"; echo -e "${DIM}$(printf '─%.0s' {1..50})${NC}"; }

# Variables
DOTFILES_URL="https://github.com/alexandroskw/dotfiles"
DOTFILES_DIR="$HOME/dotfiles"
ALACRITTY_THEMES_URL="https://github.com/alacritty/alacritty-theme"
ALACRITTY_THEMES_DIR="$HOME/.config/alacritty/themes/"
TPM_URL="https://github.com/tmux-plugins/tpm"
TPM_DIR="$HOME/.tmux/plugins/tpm/"

# Function for clone all the repos
set -e

# Changing to User home directory if you are in the Forge directory
cd "$HOME"

cloning_repos() {
    local repo_url="$1"
    local dir_target="$2"
    local repo_name="${3:-$(basename "$repo_url")}"

    # Verifiying the exact name of the cloned repository
    if [ -d "$repo_target" ]; then
        info "$repo_name already exist. Skipping..."
        return 0
    fi

    info "Cloning $repo_name..."
    if git clone "$repo_url" "$dir_target"; then
        success "Forge of $repo_name was sucessful"
    else
        error "Failed to clone the $repo_name"
        exit 1
    fi
}

# Verifying the existance of the repository
if ! command -v stow &>/dev/null; then
    error "Stow is not installed. Exiting the forge..."
    exit 1
fi

section "Applying stow"
cd "$DOTFILES_DIR"
stow_packages() {
    local pkg="$1"
    if [ -d "$pkg" ]; then
        if stow "$pkg"; then
            success "stow: $pkg"
        else
            warning "stow to $pkg failed"
        fi
    else
        warning "$pkg directory not found in the dotfiles"
    fi
}

stow_packages alacritty
stow_packages nvim
stow_packages tmux
stow_packages Scripts
stow_packages fonts

# Aditional repos
section "Repos adicionales"
mkdir -p "$ALACRITTY_THEMES_DIR"
cloning_repos "$ALACRITTY_THEMES_URL" "$ALACRITTY_THEMES_DIR" "Alacritty Themes"
cloning_repos "$TPM_URL" "$TPM_DIR" "Tmux Plugin Manager"

# Installing Rust lang first
section "Rust"
if command -v rustup &>/dev/null; then
    info "Rust is already installed. Skipping..."
else
    info "Installing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    success "Rust installed successfuly"
fi

# Installing Starship framework
section "Starship prompt"
if command -v rustup &>/dev/null; then
    info "Starship prompt is already installed. Skipping..."
else
    info "Installing Starship prompt"
    curl -sS https://starship.rs/install.sh | sh
    success "Starship installed successfuly"
fi
