#!/bin/bash

DOTFILES_URL="https://github.com/alexandroskw/dotfiles"
NAME="dotfiles"
ALACRITTY_THEMES_URL="https://github.com/alacritty/alacritty-theme"
THEMES_FOLDER="themes"
TPM_URL="https://github.com/tmux-plugins/tpm"
TPM_DIR="$HOME/tmux/plugins/tpm"

# Changing to $HOME directory if you are in the Forge directory
cd ~

# Verifying the existance of the repository
if [ -d "$NAME" ]; then
        echo "The dotfiles repository already cloned. Skipping..."
else
        echo "Cloning the repo. Wait..."
        git clone "$DOTFILES_URL"
fi

# Verifying the cloned repo was successfuly
if [ $? -eq 0 ]; then
        echo "Moving to the dotfiles repo"
        cd "$NAME"
        stow nvim
        stow alacritty
        stow tmux
        stow Scripts
else
        echo "Failed to clone the Dotfiles repository. Exiting..."
        exit 1
fi

# Cloning the Alacritty themes repository
cd "$HOME/.config/alacritty/" # Changing to the alacritty config path


if [ ! -d "$THEMES_FOLDER" ]; then
        echo "The folder is not forged. Creating and cloning..."
        # Creating the folder for the Alacritty themes repo
        git clone "$ALACRITTY_THEMES_URL" "$THEMES_FOLDER"
else
        echo "The folder is forged. Skipping..."
fi

# Cloning the TPM for TMUX
if [ -d "$TPM_DIR" ]; then
        echo "The folder is not forged. Creating and cloning..."
fi

# Installing Starship framework
STARSHIP="curl -sS https://starship.rs/install.sh | sh"

# Function for clone all the packages
cloning_repos() {
        local repo=("$@")

        if [ ! -d "$@" ]; then
                echo "The ${@} is not forged. Creating and cloning"
        fi
}
