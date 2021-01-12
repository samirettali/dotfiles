#!/usr/bin/env sh

# Prerequisites:
#   - git
#   - zsh

# Check if zsh and git are installed
command -v git >/dev/null 2>&1 || { echo >&2 "Git is required, aborting."; exit 1; }
command -v zsh >/dev/null 2>&1 || { echo >&2 "Zsh is required, aborting."; exit 1; }

# Dotfiles installation
git clone --bare https://github.com/samirettali/dotfiles $HOME/.cfg
function dots {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
dots checkout
if [ $? = 0 ]; then
    echo "Checked out config.";
else
    echo "Backing up pre-existing dot files.";
    mkdir -p $HOME/.config-backup
    dots checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} $HOME/.config-backup/{}
fi;
dots checkout
dots config --local status.showUntrackedFiles no

# Install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Zsh plugings
mkdir -p $HOME/.zsh
git -C "$HOME/.zsh" clone https://github.com/wwalker/ssh-find-agent
git -C "$HOME/.zsh" clone https://github.com/zsh-users/zsh-autosuggestions
git -C "$HOME/.zsh" clone https://github.com/starcraftman/zsh-git-prompt
git -C "$HOME/.zsh" clone https://github.com/zsh-users/zsh-syntax-highlighting

if hash stack 2>/dev/null; then
  echo "Haskell detected, compiling zsh-git-prompt..."
  cd "${HOME}/.zsh/zsh-git-prompt"
  stack setup
  stack install
else
  echo "Haskell (stack) is not installed, using normal zsh-git-prompt"
fi
