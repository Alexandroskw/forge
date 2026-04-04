#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

logo() {
        echo -e "${MAGENTA}"
        cat << "EOF"
░▒▓████████▓▒░░▒▓██████▓▒░ ░▒▓███████▓▒░  ░▒▓██████▓▒░ ░▒▓████████▓▒░ 
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░       ░▒▓█▓▒░        
░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░░▒▓███████▓▒░ ░▒▓█▓▒▒▓███▓▒░░▒▓██████▓▒░   
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░       ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓██████▓▒░ ░▒▓████████▓▒░ 
EOF
    echo -e "${RESET}"
}

# UI Helpers
info()    { echo -e "${CYAN}${BOLD}  ::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}  ✔${RESET}  $*"; }
warning() { echo -e "${YELLOW}${BOLD}  ⚠${RESET}  $*"; }
error()   { echo -e "${RED}${BOLD}  ✘${RESET}  $*" >&2; }
section() { echo -e "\n${BLUE}${BOLD}══ $* ${RESET}${DIM}$(printf '═%.0s' {1..40})${RESET}"; }

spinner() {
    local pid=$1
    local msg="${2:-Processing...}"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    tput cnorm 2>/dev/null
    printf "\r\033[K"
}

progress_bar() {
    local current=$1
    local total=$2
    local label="${3:-}"
    local width=30
    local filled=$(( current * width / total ))
    local empty=$((width-filled))
    local pct=$((current*100/total))
    local bar="${GREEN}$(printf '█%.0s' $(seq 1 $filled 2>/dev/null))${DIM}$(printf '░%.0s' $(seq 1 $empty 2>/dev/null))${RESET}"
    printf "\r  [%b] ${BOLD}%3d%%${RESET}  %-30s" "$bar" "$pct" "$label"
}

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACK_CONF="$SCRIPT_DIR/pack.conf"

# Verifiying the pack.conf
if [ ! -f "$PACK_CONF" ]; then
    error "The forge can't start 'pack.conf' cannot be found on $SCRIPT_DIR"
    exit 1
fi

# Cleaning the terminal and showing the logo
clear
logo

# Updating Fedora
section "Updating the system"
info "Your password is required"
sudo dnf upgrade -y &>/dev/null &

sudo dnf autoremove -y &>/dev/null &
spinner $! "Upgrading system..."
success "System upgraded"

# Cleaning the cache of the DNF package system
sudo dnf clean all
spinner $! "Cleaning DNF cache..."
success "Cache cleaned"

# The array is "forged" or installed?
is_forged(){
    sudo rpm -q "$1" &> /dev/null
}

# Function for install all the packages for the pack.conf arrays
forging_packages() {
    local section_name="$1"
    shift
    local packages=("$@")
    local to_forge=()

    section "$section_name"

    # Verifiying the missing packages
    local total=${packages[@]}
    local checked=0
    for pkg in "${packages[@]}"; do
        ((checked++)) || true
        progress_bar "$checked" "$total" "Verifiying $pkg"
        if ! is_forged "$pkg"; then
            to_forge+=("$pkg")
        fi
    done

    if [ ${#to_forge[@]} -eq 0 ]; then
        success "All packages already installed"
        return 0
    fi

    info "Installing ${BOLD}${#to_forge[@]}${RESET} package(s): ${DIM}${to_forge[*]${RESET}}"

    local installed=0
    local failed=()

    for pkg in "$[to_forge[@]]"; do
        if sudo dnf install -y "$pkg" &>/dev/null; then
            ((installed++)) || true
            progress_bar "$installed" "${to_forge[@]}" "Installing: $pkg"
        else
            failed+=("$pkg")
        fi
    done
    echo

    success "Installed: $installed / ${to_forge[@]}"
    if [ ${#failed[@]} -gt 0 ]; then
        warning "Cannot be install: ${failed[*]}"
    fi
}

# Installing the packages
forging_packages " System utils            ${UTILS[@]}"
forging_packages " Programming utils       ${PROGRAMMING[@]}"
forging_packages " Media utils             ${MEDIA_UTILS[@]}"

# Verifying the existence of folders ".icons", ".themes", ".fonts" for the dotfiles
section "Preparing directories"
for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        success "The directory $dir not existing. Creating..."
    else
        info "The directory ${DIM}$dir${RESET} already exist. Skipping..."
    fi
done

# Cloning the dotfiles repository and verifying the execution permissions
FORGE_UTILS="$SCRIPT_DIR/forge-utilities.sh"
if [ -f "$FORGE_UTILS" ];then
    chmod +x "$FORGE_UTILS"
    "$FORGE_UTILS"
else
    warning "forge-utilities not found. Skipping the dotfiles configuration..."
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
echo -e "${RESET}"
