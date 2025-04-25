#!/bin/bash

# Forcing the script running as sudo
if [ "$EUID" -ne 0]; then
        echo "Run this script as sudo ($0)"
        echo "Exiting..."
        exit 1
fi

# Cleaning the terminal
clear

# Updating Fedora
echo "Updating the System. Please wait..."
dnf upgrade -y
dnf autoremove -y

# Cleaning the cache of the DNF system
dnf clean all

# Necessary arrays for the instalation
souce "$(dirname "$0")/pack.conf"

# Verifying the existance of folders ".icons", ".themes", ".fonts" for the dotfiles
for dir in "${DIRECTORIES[@]}"; do
        if [ ! -d "$dir" ]; then
                echo "The directory $dir not existing. Creating..."
                mkdir -p "$dir"
        else
                echo "The directory already exist. Skipping..."
        fi
done
