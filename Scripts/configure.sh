#!/bin/sh

# software to install
SOFTWARE="zsh git neovim ack tree ctags curl wget ncdu"

# software upgrade and installation
if uname -a | grep -i 'arch' > /dev/null 2>/dev/null; then
	sudo pacman -Syu --noconfirm
	sudo pacman -S $SOFTWARE
elif uname -a | grep -i 'ubuntu\|debian' > /dev/null 2>/dev/null; then
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y $SOFTWARE
fi

# dotfiles installation
git clone --bare https://github.com/samirettali/dotfiles $HOME/.cfg
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
    echo "Checked out config.";
else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config --local status.showUntrackedFiles no

# tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# zplug
zsh -c "$(curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh && exit)"

# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# restore zshrc after oh my zsh installation
mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc

# zsh-plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
