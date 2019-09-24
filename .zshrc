ZSH="$HOME/.oh-my-zsh"

# Auto update oh-my-zsh
UPDATE_ZSH_DAYS=1

# Reduce time to enter normal mode
KEYTIMEOUT=1

ZSH_THEME="samir"

ENABLE_CORRECTION="false"

# Text editor
export EDITOR=nvim

# PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.gem/ruby/2.3.0/bin:$PATH
export PATH=$HOME/Library/Python/3.7/bin:$PATH

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git git-prompt colored-man-pages colorize fzf pip python \
    zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# # Add a package to completion right after install
zstyle ':completion:*' rehash true
# # Mismatch completion
zstyle ':completion:*' completer _complete _match _approximate
# zstyle ':completion:*:match:*' original only
# zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Don't autocomplete with files already present in the command
zstyle ':completion::complete:(rm|vi|vim|diff|mv):*' ignore-line true

source ~/.zsh_aliases
source ~/.zsh_functions

bindkey -v

bindkey '^ ' autosuggest-accept
bindkey '^R' fzf-history-widget

# Options
unsetopt HIST_IGNORE_SPACE

# Switch between foreground and background
zle -N fg-bg
bindkey '^Z' fg-bg

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

# Automatically start tmux in ssh sessions
if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
    tmux attach-session -t ssh || tmux new-session -s ssh
fi
