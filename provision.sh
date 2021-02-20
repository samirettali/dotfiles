#!/usr/bin/env bash

set -euf
set -o pipefail

print_message() {
  GREEN="\033[0;32m"
  NC="\033[0m"
  echo -e "${GREEN}[*]${NC} ${*}"
}

provision_macos() {
  # Install brew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  brew install git stow tmux fzf golang restic rustup yarn ripgrep pass \
    pass-otp fd ncdu federico-terzi/espanso pipenv youtube-dl entr

  brew install --cask alacritty keepassxc brave-browser rectangle typora \
  font-sauce-code-pro-nerd-font karabiner-elements  maccy cleanshot iina \
    homebrew/cask-drivers/logitech-options alfred iina firefox

  brew install --head neovim

  # Make standard directories for neovim
  mkdir -p ~/.local/share/nvim/undo
  mkdir -p ~/.local/share/nvim/tmp
  mkdir -p ~/.local/share/nvim/swap

  # Initialize some software
  rustup-init
  espanso register
  espanso start

  # Manual stuff (unfortunately for now)
  # System
  # * Autohide dock
  # * Remove recents from dock
  # * Scroll direction
  # * Set keyboard repeat and delay
  # * Set hostname

  # zsh
  # * Change conflicting language switch shortcut to Cmd+Shift+L
  # Run `compaudit | xargs chmod g-w` if there are compaudit insecure directories warnings

  # Alfred
  # * Disable Spotlight shortcuts
  # * Change shortcut to Cmd+Space

  # Maccy
  # * Set shortcut to Cmd+Shift+V
  # * Add `org.keepassxc.keepassxc` to blacklisted apps
}

# Detect the operating system in order to know which dotfiles to install
if [[ "${OS}" = "Darwin" ]]; then
  print_message "MacOS detected"
  provision_macos
elif [[ "${OS}" = "Linux" ]]; then
  print_message "Linux detected"
  modules=("common" "linux")
fi

