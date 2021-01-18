autoload -Uz compinit && compinit

source ~/.zsh_aliases
source ~/.zsh_functions
source ~/.zsh_env

# Immediately write commands into history file and load it as soon as it changes
setopt SHARE_HISTORY

# Do not save duplicate commands
setopt HIST_FIND_NO_DUPS

# Add a package to completion right after install
zstyle ':completion:*' rehash true

# Mismatch completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Don't autocomplete with files already present in the command
zstyle ':completion::complete:(rm|vi|vim|diff|mv):*' ignore-line true

bindkey -v

# Options
unsetopt HIST_IGNORE_SPACE

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

# Autosuggestions plugin
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

# Highlight plugin
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# FZF plugin
[ $(uname) = 'Darwin' ] && \
  source /usr/local/opt/fzf/shell/key-bindings.zsh || \
  source /usr/share/fzf/key-bindings.zsh
bindkey '^R' fzf-history-widget
bindkey '^F' fzf-file-widget

# # # SSH agent
# [ -d ~/.zsh/ssh-find-agent ] && \
#   source ~/.zsh/ssh-find-agent/ssh-find-agent.zsh
# eval "$(ssh-agent -s)"

# Git plugin
if [ -d ~/.zsh/zsh-git-prompt ]; then
  source ~/.zsh/zsh-git-prompt/zshrc.sh
  if [[ -f "${HOME}/.zsh/zsh-git-prompt/src/.bin/gitstatus" ]]; then
    GIT_PROMPT_EXECUTABLE="haskell"
  fi
  export ZSH_THEME_GIT_PROMPT_CACHE=1
  export ZSH_THEME_GIT_PROMPT_PREFIX='['
  export ZSH_THEME_GIT_PROMPT_SUFFIX=']'
  export ZSH_THEME_GIT_PROMPT_SEPARATOR=''
  export RPROMPT='$(git_super_status)'
fi

# SSH_ENV="$HOME/.ssh/agent-environment"

# function start_agent {
#     echo "Initialising new SSH agent..."
#     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
#     echo succeeded
#     chmod 600 "${SSH_ENV}"
#     . "${SSH_ENV}" > /dev/null
#     # /usr/bin/ssh-add;
# }

# Source SSH settings, if applicable
#if [ -f "${SSH_ENV}" ]; then
#    . "${SSH_ENV}" > /dev/null
#    #ps ${SSH_AGENT_PID} doesn't work under cywgin
#    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
#        start_agent;
#    }
#else
#    start_agent;
#fi

# Automatic escaping of pasted urls, this has to be here in order to not
# interfere with zsh-autosuggestions
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

PS1="%F{blue}${SSH_CONNECTION:+%B%n@%m%B}%f%B${SSH_CONNECTION:+:}%b%F{blue}%B%1~%b%F{yellow}%B%(1j.*.)%(?..!)%b%f%B%F{red}$%f%b "

# Local configs
[ -f "${HOME}/.zshrc_local" ] && source "${HOME}/.zshrc_local"
