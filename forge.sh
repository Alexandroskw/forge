#!/bin/bash

# Forcing the script running as sudo
if [ "$EUID" -ne 0 ]; then
        echo "Run this script as sudo ($0)"
        echo "Exiting..."
        exit 1
fi

logo() {
        cat << "EOF"
        
░▒▓████████▓▒░░▒▓██████▓▒░ ░▒▓███████▓▒░  ░▒▓██████▓▒░ ░▒▓████████▓▒░ 
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░       ░▒▓█▓▒░        
░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░░▒▓███████▓▒░ ░▒▓█▓▒▒▓███▓▒░░▒▓██████▓▒░   
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░       ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓██████▓▒░ ░▒▓████████▓▒░ 
                                                                      
EOF
}

# Cleaning the terminal
clear
logo

# Updating Fedora
echo "Updating the System. Please wait..."
dnf upgrade -y
dnf autoremove -y

# Cleaning the cache of the DNF package system
dnf clean all

# Necessary arrays for the instalation
source "$(dirname "$0")/pack.conf"

# Verifying the existence of folders ".icons", ".themes", ".fonts" for the dotfiles
for dir in "${DIRECTORIES[@]}"; do
        if [ ! -d "$dir" ]; then
                echo "The directory $dir not existing. Creating..."
                mkdir -p "$dir"
        else
                echo "The directory already exist. Skipping..."
        fi
done

# The array is "forged" or installed?
is_forged(){
        dnf -q "$1" &> /dev/null
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
                echo "Installing: ${to_forge[*]}}"
                dnf install -y "${to_forge[@]}"
        fi
}

# Installing the packages
echo "󰢛 Forging the system utilities"
forging_packages "${UTILS[@]}"

echo "󰢛 Forging the programming utilities"
forging_packages "${PROGRAMMING[@]}"

echo "󰢛 Forging the media utilities"
forging_packages "${MEDIA_UTILS[@]}"

echo "󰢛 Forging the desktop utilities"
forging_packages "${DESK_UTILS[@]}"

# Cleaning again the terminal
clean
logo
echo -e "\e[33mWarning: You set ZSH as your default shell"
echo "The forge is closed. Reboot your system."
