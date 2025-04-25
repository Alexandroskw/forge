#!/bin/bash

# Forcing the script is running as sudo
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
