#!/usr/bin/env bash

install() {
  sudo pacman -S --noconfirm --needed "${@}"
}

aur() {
  paru -S --noconfirm "${@}"
}


sudo pacman -Syu --noconfirm

# Install AUR helper
install base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

install alacritty entr
install chrome-gnome-shell

# Shell stuff
install zsh wget jq tree git htop tmux fzf lazygit fd ncdu ripgrep scc ranger tig wget moreutils man openbsd-netcat tree-sitter pass pass-otp rsync

install base-devel syncthing docker openssh man sudo adobe-source-code-pro-fonts python wireguard-tools nvidia nvidia-prime > /dev/null

cargo install --git 'https://github.com/Soft/xcolor.git'

# System tools
install restic net-tools

# Keyboard customization
install interception-tools interception-caps2esc
aur interception-dual-function-keys

# Compilers
install go rustup
paru -s nerd-fonts-jetbrains-mono brave-bin neovim-nightly-bin espanso-bin

install discord keepassxc flameshot
install docker docker-compose

# Dev stuff
install python-pipenv
install kubectl
aur postman-bin visual-studio-code-bin google-cloud-sdk
install nodejs npm yarn

# Language servers
yarn global add expo-cli typescript-language-server vscode-css-languageserver-bin \
  vscode-html-languageserver-bin eslint_d
pip3 install 'python-language-server[all]'
GO111MODULE=on go get golang.org/x/tools/gopls@latest

# Ethereum
aur truffle ganache-bin

aur tela-icon-theme

# cryptsetup luksHeaderBackup "/dev/disk/by-uuid/${LUKS_UUID}" --header-backup-file "/home/${USERNAME}/arch-luks.img"

## Work
aur dotnet-sdk-2.2 aspnet-runtime-2.2 dotnet-runtime-2.2 datagrip datagrip-jre mongodb-compass
aur slack-desktop
yarn global add @openapitools/openapi-generator-cli

# xps
install nvidia nvidia-prime

install tailscale

# Enable services
sudo systemctl enable --now udevmon
sudo systemctl enable --now tailscale
sudo systemctl enable --now udevmon
sudo systemctl enable --now docker
espanso start

rustup toolchain install stable
rustup component add rls rust-analysis rust-src

# Create neovim folders
mkdir -p ~/.local/share/nvim/undo
mkdir -p ~/.local/share/nvim/tmp
mkdir -p ~/.local/share/nvim/swap

# Go to Settings > Device > Keyboard and press the '+' button at the bottom.
# Name the command as you like it, e.g. flameshot. And in the command insert /usr/bin/flameshot gui.
# Then click "Set Shortcut.." and press Prt Sc. This will show as "print".
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot '[]'
