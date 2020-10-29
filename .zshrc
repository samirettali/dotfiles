autoload -Uz compinit && compinit

source ~/.zsh_aliases
source ~/.zsh_functions
source ~/.zsh_env

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

# Switch between foreground and background
zle -N fg-bg
bindkey '^Z' fg-bg

# Fix for end, home and delete keys
if [[ -n "$TMUX" ]]; then
    bindkey "^[[1~" beginning-of-line
    bindkey "^[[4~" end-of-line
    bindkey "^[[3~" delete-char
fi

# Autosuggestions plugin
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

if [[ "$TERM" == "xterm-256color" ]]; then  
  # Automatic escaping of pasted urls, this has to be here in order to not
  # interfere with zsh-autosuggestions
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

# Highlight plugin
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# FZF plugin
source /usr/local/opt/fzf/shell/key-bindings.zsh
bindkey '^R' fzf-history-widget
bindkey '^F' fzf-file-widget

PS1="%F{blue}%B%1d%b%F{yellow}%B%(1j.*.)%(?..!)%b%f%B%F{red}$%f%b "
