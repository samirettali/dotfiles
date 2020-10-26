ZSH="$HOME/.oh-my-zsh"

# Auto update oh-my-zsh
UPDATE_ZSH_DAYS=1

# Reduce time to enter normal mode
KEYTIMEOUT=1

ZSH_THEME="samir"

# Text editor
export EDITOR=nvim

# Colorize color scheme
export ZSH_COLORIZE_STYLE="native"

# PATH
export PATH=$PYENV_ROOT/bin:$PATH:$HOME/.bin:$HOME/go/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.axiom/interact:/usr/lib/go-1.14/bin
if [ $(command -v ruby) ]; then
    export PATH="$PATH:$(ruby -r rubygems -e 'puts Gem.user_dir')"/bin
fi

if [ $(command -v python3) ]; then
    export PATH=$PATH:$(python3 -c "import sys; print(':'.join(p for p in sys.path if '$HOME' in p))")
fi

export BC_ENV_ARGS="${HOME}/.config/bc"

DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git git-prompt colored-man-pages colorize fzf pass \
    zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# # Add a package to completion right after install
zstyle ':completion:*' rehash true
# # Mismatch completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Don't autocomplete with files already present in the command
zstyle ':completion::complete:(rm|vi|vim|diff|mv):*' ignore-line true

source ~/.zsh_aliases
source ~/.zsh_functions

bindkey -v

bindkey '^ ' autosuggest-accept
bindkey '^R' fzf-history-widget
bindkey '^F' fzf-file-widget

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

# Paste auto escape
pasteinit() {
    OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
    zle -N self-insert url-quote-magic
}

pastefinish() {
    zle -N self-insert $OLD_SELF_INSERT
}

zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
