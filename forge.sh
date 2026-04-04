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

info()    { echo -e "${CYAN}${BOLD} :: ${NC}$*"; }
success()      { echo -e "${GREEN}${BOLD} ✔  ${NC}$*"; }
skip()    { echo -e "${DIM} →  $*${NC}"; }
warn()    { echo -e "${YELLOW}${BOLD} ⚠  ${NC}$*"; }
error()    { echo -e "${RED}${BOLD} ✘  ${NC}$*" >&2; }
section() { echo -e "\n${BLUE}${BOLD}▶ $*${NC}"; echo -e "${DIM}$(printf '─%.0s' {1..50})${NC}"; }

logo() {
        echo -e "${RED}"${BOLD}
        cat << "EOF"
░▒▓████████▓▒░░▒▓██████▓▒░ ░▒▓███████▓▒░  ░▒▓██████▓▒░ ░▒▓████████▓▒░ 
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░       ░▒▓█▓▒░        
░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░░▒▓███████▓▒░ ░▒▓█▓▒▒▓███▓▒░░▒▓██████▓▒░   
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░       ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓██████▓▒░ ░▒▓████████▓▒░ 
EOF
    echo -e "${NC}"
}

progress_bar() {
    local label="$1"
    local current="$2"
    local total="$3"
    local width=30
    local filled=$(( current * width / total ))
    local empty=$((width-filled))
    local pct=$((current*100/total))

    local bar=""
    local i
    for ((i=0; i<filled; i++)); do bar="█"; done
    for ((i=0; i<empty; i++)); do bar="░"; done

    printf "\r  ${CYAN}[${GREEN}%s${DIM}${CYAN}]${NC} ${BOLD}%3d%%${NC}  %s" "$bar" "$pct" "$label"
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACK_CONF="$SCRIPT_DIR/pack.conf"

# Verifiying the pack.conf
if [ ! -f "$PACK_CONF" ]; then
    error "The forge can't start 'pack.conf' cannot be found on $SCRIPT_DIR"
    exit 1
fi

source "$PACK_CONF"

# Cleaning the terminal and showing the logo
set -e
clear
logo

# Updating Fedora
section "Updating the system"
info "Your password is required..."
sudo dnf upgrade -y
sudo dnf autoremove -y
success "System upgraded"

# Cleaning the cache of the DNF package system
sudo dnf clean all
success "Cache cleaned"

# The array is "forged" or installed?
is_forged(){
    sudo dnf list installed "$1" &> /dev/null
}

# Function for install all the packages for the pack.conf arrays
forging_packages() {
    local section_name="$1"
    shift
    local packages=("$@")
    section "$section_name"
    local to_forge=()

    # Verifiying the missing packages
    local total=${packages[@]}
    local checked=0
    for pkg in "${packages[@]}"; do
        i=$(( i + 1 ))
        progress_bar "Verifiying $pkg" "$checked" "$total" 
        if ! is_forged "$pkg"; then
            to_forge+=("$pkg")
        fi
    done
    echo 

    if [ ${#to_forge[@]} -eq 0 ]; then
        success "All packages already installed"
        return 0
    fi

    info "Installing: ${BOLD}${to_forge[*]}${NC}"

    local installed=0
    local failed=()
    local total=${#to_forge[@]}

    for pkg in "${to_forge[@]}"; do
        if sudo dnf install -y "$pkg"; then
            installed=$((installed + 1))
            progress_bar "$pkg installed" "$installed" "$total"
        else
            failed+=("$pkg")
            warn "Could not install $pkg"
        fi
    done
    echo

    success "Installed: $installed / $to_forge"
    if [ ${#failed[@]} -gt 0 ]; then
        warn "Failed packages: ${failed[*]}"
    fi
}

# Installing the packages
forging_packages "System utils            ${UTILS[@]}"
forging_packages "Programming utils       ${PROGRAMMING[@]}"
forging_packages "Media utils             ${MEDIA_UTILS[@]}"

# Verifying the existence of folders ".icons", ".themes", ".fonts" for the dotfiles
section "Preparing directories..."
for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        success "The directory $dir not exist. Creating..."
    else
        info "The directory $dir already exist. Skipping..."
    fi
done

# Cloning the dotfiles repository and verifying the execution permissions
FORGE_UTILS="$SCRIPT_DIR/forge-utilities.sh"
if [ -f "$FORGE_UTILS" ]; then
    chmod +x "$FORGE_UTILS"
    "$FORGE_UTILS"
else
    warn "forge-utilities not found. Skipping the dotfiles configuration..."
fi

# Showing the logo again and a message for reboot the system
clear
logo
echo -e "${GREEN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════╗"
echo "║               󰢛 The forge is closed 󰢛                 ║"
echo "║                 Reboot your system                    ║"
echo "║                for apply the changes                  ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"
