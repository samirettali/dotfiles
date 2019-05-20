export PATH=~/.local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="samir"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

HYPHEN_INSENSITIVE="true"

# Auto update
export UPDATE_ZSH_DAYS=1

ENABLE_CORRECTION="true"

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

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

source ~/.zsh_aliases
source ~/.zsh_functions

REPORTTIME=3
export EDITOR='nvim'
export TERMINAL_THEME="dark"
# export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

bindkey '^ ' autosuggest-accept

# Fix for end, home and delete keys in tmux
if [[ -n "$TMUX" ]]; then
    bindkey "^[[1~" beginning-of-line
    bindkey "^[[4~" end-of-line
    bindkey "^[[3~" delete-char
fi

# Automatically start tmux in ssh sessions
if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
    tmux attach-session -t ssh || tmux new-session -s ssh
fi

# Remove grv alias to use grv
unalias grv

# function() {
#     oldstty=$(stty -g)

#     oldstty=$(stty -g)
#     Ps=${1:-11}
#     stty raw -echo min 0 time 0
#     printf "\e]$Ps;?\a"
#     sleep 0.1
#     read -r answer
#     result=${answer#*;}
#     stty $oldstty
#     bg=$(sed 's/[^rgb:0-9a-f/]\+$//' <<< $result)

#     r=$((0x${bg:4:2}))
#     g=$((0x${bg:9:2}))
#     b=$((0x${bg:14:2}))
#     color=$(echo "$r*0.299+$g*0.587+$b*0.114" | bc)
#     if [ $(echo "$color > 186" | bc -l) = 1 ]; then
#         export TERMINAL_THEME="light"
#     else
#         export TERMINAL_THEME="dark"
#     fi
# }

function light() {
    konsoleprofile "colors=base16-one-light"
    export TERMINAL_THEME="light"
}

function dark() {
    konsoleprofile "colors=base16-onedark"
    export TERMINAL_THEME="dark"
}
