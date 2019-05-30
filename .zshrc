export PATH=~/.local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="samir"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

HYPHEN_INSENSITIVE="true"

# Auto update
export UPDATE_ZSH_DAYS=1

ENABLE_CORRECTION="false"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git git-prompt colored-man-pages colorize fzf pip python \
    zsh-autosuggestions zsh-syntax-highlighting archlinux)

source $ZSH/oh-my-zsh.sh

# User configuration

setopt incappendhistory
# setopt printexitvalue

# Add a package to completion right after install
zstyle ':completion:*' rehash true
# Mismatch completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

source ~/.fzfrc
source ~/.zsh_aliases
source ~/.zsh_functions

REPORTTIME=3

# Reduce time to enter normal mode
export KEYTIMEOUT=1
bindkey -v

bindkey '^ ' autosuggest-accept

# Fix for end, home and delete keys in tmux
if [[ -n "$TMUX" ]]; then
    bindkey "^[[1~" beginning-of-line
    bindkey "^[[4~" end-of-line
    bindkey "^[[3~" delete-char
else
    bindkey "${terminfo[khome]}" beginning-of-line
    bindkey "${terminfo[kend]}" end-of-line
    bindkey "${terminfo[kdch1]}" delete-char
fi

# Automatically start tmux in ssh sessions
if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
    tmux attach-session -t ssh || tmux new-session -s ssh
fi

# Remove grv alias to use grv
unalias grv

# if [ $(kreadconfig5 --file ~/.config/kdeglobals --group KDE --key ColorScheme) = "Breeze" ]; then
#     export TERMINAL_THEME="light"
# #     konsoleprofile "colors=BlackOnRandomLight"
# else
#     export TERMINAL_THEME="dark"
# #     konsoleprofile "colors=SpaceGray"
# fi
export EDITOR='nvim'
export TERMINAL_THEME="dark"
export QT_QPA_PLATFORMTHEME=qt5ct
