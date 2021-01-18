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

# Ask for correction when entering a wrong command
setopt CORRECT
setopt CORRECT_ALL

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

  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
fi

# Autosuggestions plugin
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

# Highlight plugin
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# FZF plugin
bindkey '^R' fzf-history-widget
bindkey '^F' fzf-file-widget

# autoload -Uz vcs_info
# zstyle ':vcs_info:*' enable git hg
# zstyle ':vcs_info:*' check-for-changes true
# zstyle ':vcs_info:*' stagedstr "%F{green}●%f" # default 'S'
# zstyle ':vcs_info:*' unstagedstr "%F{red}●%f" # default 'U'
# zstyle ':vcs_info:*' use-simple true
# zstyle ':vcs_info:git+set-message:*' hooks git-untracked
# zstyle ':vcs_info:git*:*' formats '[%b%m%c%u] ' # default ' (%s)-[%b]%c%u-'
# zstyle ':vcs_info:git*:*' actionformats '[%b|%a%m%c%u] ' # default ' (%s)-[%b|%a]%c%u-'
# zstyle ':vcs_info:hg*:*' formats '[%m%b] '
# zstyle ':vcs_info:hg*:*' actionformats '[%b|%a%m] '
# zstyle ':vcs_info:hg*:*' branchformat '%b'
# zstyle ':vcs_info:hg*:*' get-bookmarks true
# zstyle ':vcs_info:hg*:*' get-revision true
# zstyle ':vcs_info:hg*:*' get-mq false
# zstyle ':vcs_info:hg*+gen-hg-bookmark-string:*' hooks hg-bookmarks
# zstyle ':vcs_info:hg*+set-message:*' hooks hg-message

# function +vi-hg-bookmarks() {
#   emulate -L zsh
#   if [[ -n "${hook_com[hg-active-bookmark]}" ]]; then
#     hook_com[hg-bookmark-string]="${(Mj:,:)@}"
#     ret=1
#   fi
# }

# function +vi-hg-message() {
#   emulate -L zsh
#   # Suppress hg branch display if we can display a bookmark instead.
#   if [[ -n "${hook_com[misc]}" ]]; then
#     hook_com[branch]=''
#   fi
#   return 0
# }

# function +vi-git-untracked() {
#   emulate -L zsh
#   if [[ -n $(git ls-files --exclude-standard --others 2> /dev/null) ]]; then
#     hook_com[unstaged]+="%F{blue}●%f"
#   fi
# }

# export RPROMPT_BASE=\${vcs_info_msg_0_}
# setopt prompt_subst
# export RPROMPT=$RPROMPT_BASE

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{white}[%b]%f'
zstyle ':vcs_info:*' enable git

function () {
  if [[ -n "$TMUX" ]]; then
    local LVL=$(($SHLVL - 1))
  else
    local LVL=$SHLVL
  fi

  if [[ $EUID -eq 0 ]]; then
    local SUFFIX=$(printf '#%.0s' {1..$LVL})
  else
    local SUFFIX=$(printf '$%.0s' {1..$LVL})
  fi

  # Show user@host if I'm in SSH or docker
  if [[ $SSH_CONNECTION ]] || [[ -f /.dockerenv ]]; then
    local PREFIX="${%n@%m}"
  fi

  export PS1="%B%F{green}${PREFIX}%F{blue}%1~%F{yellow}%(1j.*.)%(?..!)%f%F{red}${SUFFIX}%f%b "
}
export SPROMPT="zsh: correct %F{red}%B'%R'%b%f to %F{green}%B'%r'%b%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "

# PS1="%F{blue}${SSH_CONNECTION:+%B%n@%m%B}%f%B${SSH_CONNECTION:+:}%b%F{blue}%B%1~%b%F{yellow}%B%(1j.*.)%(?..!)%b%f%B%F{red}$%f%b "
