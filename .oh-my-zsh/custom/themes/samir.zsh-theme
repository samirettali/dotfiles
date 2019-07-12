# prompt

# ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}["
# ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_CLEAN=""

# # show git branch/tag, or name-rev if on detached head
# parse_git_branch() {
#   (command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
# }

# # show red star if there are uncommitted changes
# parse_git_dirty() {
#   if command git diff-index --quiet HEAD 2> /dev/null; then
#     echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
#   else
#     echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
#   fi
# }

# git_custom_status() {
#   local git_where="$(parse_git_branch)"
#   [ -n "$git_where" ] && echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX${git_where#(refs/heads/|tags/)}$ZSH_THEME_GIT_PROMPT_SUFFIX"
# }

RPROMPT_BASE='%F{red}$(vi_mode_prompt_info)%f $(git_super_status)'

function () {
    # Check for tmux by looking at $TERM, because $TMUX won't be propagated to any
    # nested sudo shells but $TERM will.
    if [ -n "$TMUX" ] || [ -n "$SSH_CONNECTION" ]; then
        # In a a tmux session created in a non-root or root shell.
        local LVL=$SHLVL-1
    else
        # Either in a root shell created inside a non-root tmux session,
        # or not in a tmux session.
        local LVL=$SHLVL
    fi
    # Check if the current shell is being executed by root to append # or $
    # accordingly
    if [[ $EUID -eq 0 ]]; then
        local SUFFIX='%F{yellow}%n%f'$(printf '%%F{yellow}#%.0s%%f' {1..$LVL})
    else
        local SUFFIX=$(printf '%%F{red}$%.0s%%f' {1..$LVL})
    fi
    export PS1="%F{blue}${SSH_CONNECTION:+%B%n@%m%B}%f%B${SSH_CONNECTION:+:}%b%F{blue}%B%1d%b%F{yellow}%B%(1j.*.)%(?..!)%b%f%B${SUFFIX}%b "
}
# export RPROMPT="\$(git_custom_status) " #%F{blue}%~%b"
export SPROMPT="zsh: correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "

# Updates editor information when the keymap changes.
function zle-keymap-select() {
    zle reset-prompt
    zle -R
}

zle -N zle-keymap-select

function vi_mode_prompt_info() {
    echo "${${KEYMAP/vicmd/🔒}/(main|viins)/}"
}

typeset -F SECONDS
function -record-start-time() {
  emulate -L zsh
  ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
}
add-zsh-hook preexec -record-start-time

function -report-start-time() {
  emulate -L zsh
  if [ $ZSH_START_TIME ]; then
    local DELTA=$(($SECONDS - $ZSH_START_TIME))
    local DAYS=$((~~($DELTA / 86400)))
    local HOURS=$((~~(($DELTA - $DAYS * 86400) / 3600)))
    local MINUTES=$((~~(($DELTA - $DAYS * 86400 - $HOURS * 3600) / 60)))
    local SECS=$(($DELTA - $DAYS * 86400 - $HOURS * 3600 - $MINUTES * 60))
    local ELAPSED=''
    test "$DAYS" != '0' && ELAPSED="${DAYS}d"
    test "$HOURS" != '0' && ELAPSED="${ELAPSED}${HOURS}h"
    test "$MINUTES" != '0' && ELAPSED="${ELAPSED}${MINUTES}m"
    if [ "$ELAPSED" = '' ]; then
      SECS="$(print -f "%.2f" $SECS)s"
    elif [ "$DAYS" != '0' ]; then
      SECS=''
    else
      SECS="$((~~$SECS))s"
    fi
    ELAPSED="${ELAPSED}${SECS}"
    export RPROMPT="%F{cyan}%{$__WINCENT[ITALIC_ON]%}${ELAPSED}%{$__WINCENT[ITALIC_OFF]%}%f $RPROMPT_BASE"
    unset ZSH_START_TIME
  else
    export RPROMPT="$RPROMPT_BASE"
  fi
}
add-zsh-hook precmd -report-start-time
