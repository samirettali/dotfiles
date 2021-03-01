autoload -Uz compinit
compinit

source ~/.zsh_aliases
source ~/.zsh_functions
source ~/.zsh_env
[ -f "${HOME}/.zshrc_local" ] && source "${HOME}/.zshrc_local"

# Use vim bindings (of course)
bindkey -v

# Immediately write commands into history file and load it as soon as it changes
setopt SHARE_HISTORY

# Do not store duplicate commands
setopt HIST_IGNORE_DUPS

# Remove blank lines from history
setopt HIST_REDUCE_BLANKS

# Case insensitive globbing
setopt NO_CASE_GLOB

# Case insensitive globbing
setopt AUTO_CD

# Options
unsetopt HIST_IGNORE_SPACE

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(@s.:.)LSCOLORS}"
zstyle ':completion:*' completer _last_command_args _complete

# Add a package to completion right after install
zstyle ':completion:*' rehash true

# Mismatch completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Don't autocomplete with files already present in the command
zstyle ':completion::complete:(rm|vi|vim|diff|mv):*' ignore-line true

# Complete by expanding
zstyle ':completion:*' list-suffixeszstyle ':completion:*' expand prefix suffix 

# Reduce time to enter normal mode
KEYTIMEOUT=1

# Set autocomplete options for vman
compdef vman="man"

# Switch between foreground and background
zle -N fg-bg
bindkey '^Z' fg-bg

# Fix for end, home and delete keys
if [[ -n "$TMUX" ]]; then
    bindkey "^[[1~" beginning-of-line
    bindkey "^[[4~" end-of-line
    bindkey "^[[3~" delete-char
fi

# Disable r command
disable r

# This has to be before zsh-autosuggestions
if [[ "$TERM" == "xterm-256color" ]]; then
  autoload -U url-quote-magic bracketed-paste-magic
  zle -N self-insert url-quote-magic
  zle -N bracketed-paste bracketed-paste-magic

  pasteinit() {
      OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
      zle -N self-insert url-quote-magic
  }

  pastefinish() {
      zle -N self-insert $OLD_SELF_INSERT
  }

  zstyle :bracketed-paste-magic paste-init pasteinit
  zstyle :bracketed-paste-magic paste-finish pastefinish

  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste accept-line)
fi

# FZF shortcuts
bindkey '^R' fzf-history-widget
bindkey '^F' fzf-file-widget

# Git prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{magenta}%B[%b]%%b%f'
zstyle ':vcs_info:*' enable git

# Prompt (Heavily inspired from Greg Hurrell)
# https://github.com/wincent/wincent
function () {
  if [[ -n "$TMUX" ]]; then
    local LVL=$(($SHLVL - 1))
  else
    local LVL=$SHLVL
  fi

  if [[ $EUID -eq 0 ]]; then
    local SUFFIX=$(printf '#%.0s' {1..$LVL})
  else
    local SUFFIX=$(printf '\$%.0s' {1..$LVL})
  fi

  # Show user@host if I'm in SSH or docker
  if [[ $SSH_CONNECTION ]] || [[ -f /.dockerenv ]]; then
    export PS1="%B%F{blue}%n@%m%f:%F{blue}%1~%F{yellow}%(1j.*.)%(?..!)%f%F{red}${SUFFIX}%f%b "
  else
    export PS1="%B%F{blue}%1~%F{yellow}%(1j.*.)%(?..!)%f%F{red}${SUFFIX}%f%b "
  fi
}

# Autosuggestions plugin
export ZSH_AUTOSUGGEST_USE_ASYNC=1
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

# Highlight plugin
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
