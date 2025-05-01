# FORGE
Welcome to the
░▒▓████████▓▒░░▒▓██████▓▒░ ░▒▓███████▓▒░  ░▒▓██████▓▒░ ░▒▓████████▓▒░ 
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░        
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░       ░▒▓█▓▒░                                                                                                                                          ## The __problem__
░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░░▒▓███████▓▒░ ░▒▓█▓▒▒▓███▓▒░░▒▓██████▓▒░                                                                                                                                     Every time I install Fedora in a new computer, I always open the terminal and start typing `sudo dnf install ...`
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░                                                                                                                                          It's so annoying typing every time the same and remember what packages I missed to install and set my aliases in the
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░                                                                                                                                          bash config.
░▒▓█▓▒░       ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓██████▓▒░ ░▒▓████████▓▒░ 
## The __solution__
Inspired in a YouTube video, I see what I can automatize the installing the all stuff only running a simple bash script.
So I decided to try it my self and make my own bash script to automatize the installation of my [dotfiles](https://github.com/Alexandroskw/dotfiles)

## Usage
You can use this script if you want. Only you need to clone the repo
```
git clone https://github.com/Alexandroskw/forge
```
Once you cloned go to the folder `cd ~/forge` and make executable the file **forge.sh** and then run it
```
chmod +x forge.sh
./forge.sh
```
or

```
chmod +x forge.sh && ./forge.sh
```
The script automatically install the packages, clone the necessary repos for the correct function of my own stuff

> [!NOTE]
> You should manually stow the `.bashrc` file for avoiding any trouble. But it is a good practice to make a backup of your
own .bashrc configuration.

When the script finished to install all the packages and clone the repos, will ask you to reboot your system for make
changes effective

> [!WARNING]
> The script will delete your configurations if you have it for the packages Alacritty, Tmux, NeoVim, Fastfetch and Starship.
Take your own risk for the use of this script.
