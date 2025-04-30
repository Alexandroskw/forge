#!/bin/bash

# Variables
DOTFILES_URL="https://github.com/alexandroskw/dotfiles"
DOTFILES_DIR="$HOME/dotfiles"
ALACRITTY_THEMES_URL="https://github.com/alacritty/alacritty-theme"
ALACRITTY_THEMES_DIR="$HOME/.config/alacritty/themes/"
TPM_URL="https://github.com/tmux-plugins/tpm"
TPM_DIR="$HOME/.tmux/plugins/tpm/"

set -e

# Changing to User home directory if you are in the Forge directory
cd "$HOME"

# Verifying the existance of the repository
if [ -d "$DOTFILES_DIR" ]; then
        echo "The dotfiles repository already cloned. Skipping..."
else
        echo "Cloning the repo. Wait..."
        git clone "$DOTFILES_URL" "$DOTFILES_DIR"
fi

if ! command -v stow &> /dev/null; then
        echo "Stow is not installed. Exiting the forge..."
        exit 1
fi

# Verifying the cloned repo was successfuly
if [ $? -eq 0 ]; then
        echo "Moving to the dotfiles repo for copy the dotfiles"
        cd "$DOTFILES_DIR"
        stow alacritty
        stow nvim
        stow tmux
        stow Scripts
        stow fonts
else
        echo "Failed to clone the Dotfiles repository. Exiting..."
        exit 1
fi

# Function for clone all the repos
cloning_repos() {
        local repo_url="$1"
        local dir_target="$2"
        local repo_name="$3"

        # Verifiying the exact name of the cloned repository
        if [ -z "$repo_name" ]; then
                repo_name="$dir_target"
        fi

        if [ -d "$dir_target" ]; then
                echo "The $repo_name already cloned. Skipping..."
        else
                echo "Forging the repo $repo_name"
                git clone "$repo_url" "$dir_target"
        fi

        local git_result=$?
        if [ $git_result -eq 0 ]; then
                echo "Forge of $repo_name was sucessful"
        else
                echo "Failed to clone the $repo_name"
                exit 1
        fi
}

# Cloning the Alacritty themes repository
if ! cloning_repos "$ALACRITTY_THEMES_URL" "$ALACRITTY_THEMES_DIR"; then
        echo "Failed to clone the Alacritty themes repo"
        exit 1
fi

# Cloning the Tmux Plugin Manager repository
if ! cloning_repos "$TPM_URL" "$TPM_DIR"; then
        echo "Failed to clone the TPM repo"
        exit 1
fi

# Installing Rust lang first
echo "Installing Rust lang"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Installing Starship framework
echo "Installing Starship prompt framework"
curl -sS https://starship.rs/install.sh | sh
