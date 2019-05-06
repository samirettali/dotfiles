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

plugins=(git git-prompt colored-man-pages colorize pip python \
    zsh-autosuggestions zsh-syntax-highlighting)

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
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

bindkey '^ ' autosuggest-accept

if [[ -n "$TMUX" ]]; then
    bindkey "^[[1~" beginning-of-line
    bindkey "^[[4~" end-of-line
    bindkey "^[[3~" delete-char
fi
