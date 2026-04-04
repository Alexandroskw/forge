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

# Cleaning the cache of the DNF package system
sudo dnf clean all

# The array is "forged" or installed?
is_forged(){
    sudo dnf -q "$1" &> /dev/null
}

# Function for install all the packages for the pack.conf arrays
forging_packages() {
    local packages=("$@")
    local to_forge=()

    for f in "${packages[@]}"; do
        if ! is_forged "$f"; then
            to_forge+=("$f")
        fi
    done

    if [ ${#to_forge[@]} -ne 0 ]; then
        echo "Installing: ${to_forge[*]}"
        sudo dnf install -y "${to_forge[@]}"
    fi
}

# Necessary arrays for the instalation
source "$(dirname "$0")/pack.conf"

# Verifiying the pack.conf exists
if [ ! -f "pack.conf" ]; then
    echo "The forge can't start. The 'pack.conf' not found"
    exit 1
fi

# Installing the packages
echo "󰢛 Forging the system utilities"
forging_packages "${UTILS[@]}"

echo "󰢛 Forging the programming utilities"
forging_packages "${PROGRAMMING[@]}"

echo "󰢛 Forging the media utilities"
forging_packages "${MEDIA_UTILS[@]}"

echo "󰢛 Forging the desktop utilities"
forging_packages "${DESK_UTILS[@]}"

# Verifying the existence of folders ".icons", ".themes", ".fonts" for the dotfiles
for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "The directory $dir not existing. Creating..."
        mkdir -p "$dir"
    else
        echo "The directory already exist. Skipping..."
    fi
done

# Cloning the dotfiles repository and verifying the execution permissions
if [ -f "$(dirname "$0")/forge-utilities.sh" ];then
    chmod +x "$(dirname "$0")/forge-utilities.sh"
    "$(dirname "$0")/forge-utilities.sh"
else
    echo "forge-utilities not found. Skipping the dotfiles configuration..."
fi

# Showing the logo again and a message for reboot the system
logo
echo "╔═══════════════════════════════════════════════════════╗"
echo "║               󰢛 The forge is closed 󰢛                 ║"
echo "║                 Reboot your system                    ║"
echo "╚═══════════════════════════════════════════════════════╝"
