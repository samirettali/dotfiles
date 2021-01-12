#!/usr/bin/env bash

set -euf
set -o pipefail

# Check if git and stow are installed
command -v git >/dev/null 2>&1 || { echo >&2 "git is required, aborting."; exit 1; }
command -v stow >/dev/null 2>&1 || { echo >&2 "stow is required, aborting."; exit 1; }

print_message() {
  GREEN="\033[0;32m"
  NC="\033[0m"
  echo -e "${GREEN}[*]${NC} ${*}"
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"

# Install tmux plugin manager
if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
  mkdir -p "${HOME}/.tmux/plugins"
  print_message "Installing tmux plugin manager"
  git -C "${HOME}/.tmux/plugins" clone --quiet https://github.com/tmux-plugins/tpm
fi

# Zsh plugings
ZSH_PLUGINS="${HOME}/.zsh"

if [ ! -d "${ZSH_PLUGINS}" ]; then
  mkdir -p "${ZSH_PLUGINS}"
fi

if [ ! -d "${ZSH_PLUGINS}/ssh-find-agent" ]; then
  print_message "Installing ssh-find-agent"
  git -C "${ZSH_PLUGINS}" clone --quiet https://github.com/wwalker/ssh-find-agent
fi
if [ ! -d "${ZSH_PLUGINS}/zsh-autosuggestions" ]; then
  print_message "Installing zsh-autosuggestions"
  git -C "${ZSH_PLUGINS}" clone --quiet https://github.com/zsh-users/zsh-autosuggestions
fi
if [ ! -d "${ZSH_PLUGINS}/zsh-git-prompt" ]; then
  print_message "Installing zsh-git-prompt"
  git -C "${ZSH_PLUGINS}" clone --quiet https://github.com/starcraftman/zsh-git-prompt
fi
if [ ! -d "${ZSH_PLUGINS}/zsh-syntax-highlighting" ]; then
  print_message "Installing zsh-syntax-highlighting"
  git -C "${ZSH_PLUGINS}" clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting 
fi

# stow -t "${HOME}" ack
# stow -t "${HOME}" alacritty
# stow -t "${HOME}" bc
# stow -t "${HOME}" git
# stow -t "${HOME}" mpd
# stow -t "${HOME}" ncmpcpp
# stow -t "${HOME}" nvim
# stow -t "${HOME}" ripgrep
# stow -t "${HOME}" scripts
# stow -t "${HOME}" tmux
# stow -t "${HOME}" tmuxinator
# stow -t "${HOME}" zsh

OS=$(uname)
modules=()

if [[ "${OS}" = "Darwin" ]]; then
  print_message "MacOS detected"
  modules=("common" "mac")
elif [[ "${OS}" = "Linux" ]]; then
  print_message "Linux detected"
  modules=(common linux)
else
  echo "Unsupported OS."
  exit 1
fi

for module in "${modules[@]}"; do
  print_message "Installing ${module} packages"
  # stow -t "${HOME}" -
  for package in $(find ${module} -maxdepth 1 | grep '/' | sed 's|^.*/||'); do
    print_message "${package}"
    stow -t "${HOME}" -d  "${module}" "${package}"
  done
  echo
done

print_message "Done"

# if hash stack 2>/dev/null; then
#   echo "Haskell detected, compiling zsh-git-prompt..."
#   cd "${HOME}/.zsh/zsh-git-prompt"
#   stack setup
#   stack install
# else
#   echo "Haskell (stack) is not installed, using normal zsh-git-prompt"
# fi
