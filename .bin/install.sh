#!/bin/sh

# Prerequisites:
#   - git
#   - zsh

# TODO install vim Plugins
# TODO install tmux plugins
# TODO UpdateRemotePlugins
# TODO install pip pynvim
# TODO autoupdate dots on every machine

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

# Temporarily move my zsh theme
mv $HOME/.oh-my-zsh/custom/themes/samir.zsh-theme samir.zsh-theme
rm -rf $HOME/.oh-my-zsh

# Install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install oh-my-zsh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh && exit)"

# zsh-plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Restore my zsh theme
mv samir.zsh-theme $HOME/.oh-my-zsh/custom/themes

# Restore my zshrc after oh-my-zsh installation
mv $HOME/.zshrc.pre-oh-my-zsh $HOME/.zshrc
