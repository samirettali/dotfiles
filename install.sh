#!/usr/bin/env sh

# Check if zsh and stow are installed
command -v git >/dev/null 2>&1 || { echo >&2 "git is required, aborting."; exit 1; }
command -v stow >/dev/null 2>&1 || { echo >&2 "stow is required, aborting."; exit 1; }

print_message() {
  GREEN='\033[0;32m'
  NC='\033[0m'
  echo -e "${GREEN}[*]${NC} ${*}"
}

# Install tmux plugin manager
if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
  mkdir -p "${HOME}/.tmux/plugins"
  git -C "${HOME}/.tmux/plugins" clone https://github.com/tmux-plugins/tpm
fi

# Zsh plugings
ZSH_PLUGINS="${HOME}/.zsh"

if [ ! -d "${ZSH_PLUGINS}" ]; then
  mkdir -p "${ZSH_PLUGINS}"
fi

if [ ! -d "${ZSH_PLUGINS}/ssh-find-agent" ]; then
  git -C "${ZSH_PLUGINS}" clone https://github.com/wwalker/ssh-find-agent
fi
if [ ! -d "${ZSH_PLUGINS}/zsh-autosuggestions" ]; then
  git -C "${ZSH_PLUGINS}" clone https://github.com/zsh-users/zsh-autosuggestions
fi
if [ ! -d "${ZSH_PLUGINS}/ssh-git-prompt" ]; then
  git -C "${ZSH_PLUGINS}" clone https://github.com/starcraftman/zsh-git-prompt
fi
if [ ! -d "${ZSH_PLUGINS}/ssh-syntax-highlighting" ]; then
  git -C "${ZSH_PLUGINS}" clone https://github.com/zsh-users/zsh-syntax-highlighting
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
stow $(ls -d "*/")

stow alacritty
stow bc
stow mpd
stow ncmpcpp
stow nvim
stow ripgrep
stow tmuxinator
stow zsh
stow git
stow tmux

OS=$(uname)

if [ "${OS}" = 'Darwin' ]; then
  print_message "MacOS detected"
  stow espanso
  stow karabiner
else if [ "${OS}" = 'Linux' ]; then
  print_message "Linux detected"
  stow xinit
else
  echo "Unsupported OS."
fi

# if hash stack 2>/dev/null; then
#   echo "Haskell detected, compiling zsh-git-prompt..."
#   cd "${HOME}/.zsh/zsh-git-prompt"
#   stack setup
#   stack install
# else
#   echo "Haskell (stack) is not installed, using normal zsh-git-prompt"
# fi
