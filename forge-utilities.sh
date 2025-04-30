#!/bin/bash

# Variables
SUDO_USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
DOTFILES_URL="https://github.com/alexandroskw/dotfiles"
DOTFILES_DIR="$SUDO_USER_HOME/dotfiles"
ALACRITTY_THEMES_URL="https://github.com/alacritty/alacritty-theme"
ALACRITTY_THEMES_DIR="$SUDO_USER_HOME/.config/alacritty/themes/"
TPM_URL="https://github.com/tmux-plugins/tpm"
TPM_DIR="$SUDO_USER_HOME/tmux/plugins/tpm"

# Changing to User home directory if you are in the Forge directory
cd "$SUDO_USER_HOME"

# Verifying the existance of the repository
if [ -d "$DOTFILES_DIR" ]; then
        echo "The dotfiles repository already cloned. Skipping..."
else
        echo "Cloning the repo. Wait..."
        git clone "$DOTFILES_URL"
fi

# Verifying the cloned repo was successfuly
if [ $? -eq 0 ]; then
        echo "Moving to the dotfiles repo"
        cd "$DOTFILES_DIR"
        su - "$SUDO_USER" -c "cd '$DOTFILES_DIR' && stow alacritty"
        su - "$SUDO_USER" -c "cd '$DOTFILES_DIR' && stow nvim"
        su - "$SUDO_USER" -c "cd '$DOTFILES_DIR' && stow tmux"
        su - "$SUDO_USER" -c "cd '$DOTFILES_DIR' && stow Scripts"
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

        if [ $? -eq 0 ];then
                echo "Forge of $repo_name was sucessful"
        else
                echo "Failed to clone the $repo_name"
                exit 1
        fi
}

# Cloning the Alacritty themes repository
cd "$SUDO_USER_HOME/.config/alacritty/" # Changing to the alacritty config path

cloning_repos "$ALACRITTY_THEMES_URL" "$ALACRITTY_THEMES_DIR"
# if [ ! -d "$ALACRITTY_THEMES_DIR" ]; then
#         echo "The folder is not forged. Creating and cloning..."
#         # Creating the folder for the Alacritty themes repo git clone "$ALACRITTY_THEMES_URL" "$ALACRITTY_THEMES_DIR"
# else
#         echo "The folder is forged. Skipping..."
# fi

# Cloning the TPM for TMUX
# if [ -d "$TPM_DIR" ]; then
#         echo "The folder is not forged. Creating and cloning..."
# fi

# Installing Starship framework
STARSHIP="curl -sS https://starship.rs/install.sh | sh"
