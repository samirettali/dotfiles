export PATH=~/.local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="samir"

HYPHEN_INSENSITIVE="true"

# Auto update
export UPDATE_ZSH_DAYS=1

ENABLE_CORRECTION="false"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git git-prompt colored-man-pages colorize fzf pip python \
    zsh-autosuggestions zsh-syntax-highlighting archlinux you-should-use)

source $ZSH/oh-my-zsh.sh

# User configuration

setopt incappendhistory

# Add a package to completion right after install
zstyle ':completion:*' rehash true
# Mismatch completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# source ~/.fzfrc
source ~/.zsh_aliases
source ~/.zsh_functions

bindkey -v

bindkey '^ ' autosuggest-accept
bindkey '^R' fzf-history-widget

# Fix for end, home and delete keys
if [[ -n "$TMUX" ]]; then
    bindkey "^[[1~" beginning-of-line
    bindkey "^[[4~" end-of-line
    bindkey "^[[3~" delete-char
else
    bindkey "${terminfo[khome]}" beginning-of-line
    bindkey "${terminfo[kend]}" end-of-line
    bindkey "${terminfo[kdch1]}" delete-char
fi

# Remove grv alias to use grv
unalias grv

# Reduce time to enter normal mode
export KEYTIMEOUT=1

# Option for zsh-you-should-use to force alias usage
export YSU_HARDCORE=1

# If the command takes longer than 3 seconds print the execution time
export REPORTTIME=3

export EDITOR=nvim
export TERMINAL_THEME=dark
export QT_QPA_PLATFORMTHEME=qt5ct

# Set terminal theme based on gtk theme
if [[ $(gsettings get org.gnome.desktop.interface gtk-theme) =~ "light" ]]; then
    export TERMINAL_THEME=light
else
    export TERMINAL_THEME=dark
fi

# Automatically start tmux in ssh sessions
if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
    tmux attach-session -t ssh || tmux new-session -s ssh
fi
