# The following lines were added by compinstall
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename '/home/samir/.zshrc'
autoload -Uz compinit promptinit
compinit
promptinit
# End of lines added by compinstall

# Report command running time if it is more than 3 seconds
HISTFILE=~/.histfile
REPORTTIME=3
HISTSIZE=10000
SAVEHIST=10000
unsetopt nomatch
setopt appendhistory histignorealldups autocd extendedglob correct

source ~/.zsh_aliases
source ~/.zsh_functions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

bindkey -v

# %B bold
# %F{color} start color
# %f end color
# %n username
# %m machine
# %~ directory
# %# show # if root, % otherwise
# PROMPT='%B%F{green}%n@%m%f%  %F{blue}%2~ %#%f%b '
# PROMPT='%B%F{red}%n@%m%f%F{white}:%f%F{blue}%2~%f%F{white}$%f%b '
PROMPT='%B%F{red}%n@%m%f %F{blue}%~%f %F{white}$%f%b '

RPROMPT=' %B%F{white}[%f%F{green}%?%f%F{white}]%f%B'

# use cache for auto completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# mismatch completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# add a package to completion right after install
zstyle ':completion:*' rehash true

# shortcuts
bindkey '^ ' autosuggest-accept
bindkey '^R' fzf-history-widget

stty -ixon

# Home, end and canc keys fix, run cat and press the keys to find keycodes
if [[ -n "$TMUX" ]]; then
    bindkey "^[[1~" beginning-of-line
    bindkey "^[[4~" end-of-line
    bindkey "^[[3~" delete-char
else
    bindkey "^[[H" beginning-of-line
    bindkey "^[[F" end-of-line
    bindkey "^[[3~" delete-char
fi

export EDITOR=nvim
export KEYTIMEOUT=1
export BROWSER=firefox
export WORDCHARS='*?_[]~=&;!#$%^(){}'
export KALI=/home/samir/Documents/Hacking/Kali
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

__fzfcmd() {
  __fzf_use_tmux__ &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
  selected=( $(fc -rl 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget
