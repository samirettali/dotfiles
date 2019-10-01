# prompt

ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_SEPARATOR=""
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[yellow]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{✖●%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[blue]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{↓%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[red]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
RPROMPT_BASE='%F{red}$(vi_mode_prompt_info)%f $(git_super_status)'

function () {
    if [ -n "$TMUX" ] || [ -n "$SSH_CONNECTION" ]; then
        local LVL=$SHLVL-1
    else
        local LVL=$SHLVL
    fi
    if [[ $EUID -eq 0 ]]; then
        local SUFFIX=$(printf '%%F{red}#%.0s%%f' {1..$LVL})
        # local SUFFIX='%F{yellow}%n%f'$(printf '%%F{yellow}#%.0s%%f' {1..$LVL})
    else
        local SUFFIX=$(printf '%%F{red}$%.0s%%f' {1..$LVL})
    fi
    export PS1="%F{blue}${SSH_CONNECTION:+%B%n@%m%B}%f%B${SSH_CONNECTION:+:}%b%F{blue}%B%1d%b%F{yellow}%B%(1j.*.)%(?..!)%b%f%B${SUFFIX}%b "
}
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

# typeset -F SECONDS
# function -record-start-time() {
#   emulate -L zsh
#   ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
# }
# add-zsh-hook preexec -record-start-time

# function -report-start-time() {
#   emulate -L zsh
#   if [ $ZSH_START_TIME ]; then
#     local DELTA=$(($SECONDS - $ZSH_START_TIME))
#     local DAYS=$((~~($DELTA / 86400)))
#     local HOURS=$((~~(($DELTA - $DAYS * 86400) / 3600)))
#     local MINUTES=$((~~(($DELTA - $DAYS * 86400 - $HOURS * 3600) / 60)))
#     local SECS=$(($DELTA - $DAYS * 86400 - $HOURS * 3600 - $MINUTES * 60))
#     local ELAPSED=''
#     test "$DAYS" != '0' && ELAPSED="${DAYS}d"
#     test "$HOURS" != '0' && ELAPSED="${ELAPSED}${HOURS}h"
#     test "$MINUTES" != '0' && ELAPSED="${ELAPSED}${MINUTES}m"
#     if [ "$ELAPSED" = '' ]; then
#       SECS="$(print -f "%.2f" $SECS)s"
#     elif [ "$DAYS" != '0' ]; then
#       SECS=''
#     else
#       SECS="$((~~$SECS))s"
#     fi
#     ELAPSED="${ELAPSED}${SECS}"
#     export RPROMPT="%F{cyan}%{$__WINCENT[ITALIC_ON]%}${ELAPSED}%{$__WINCENT[ITALIC_OFF]%}%f $RPROMPT_BASE"
#     unset ZSH_START_TIME
#   else
#     export RPROMPT="$RPROMPT_BASE"
#   fi
# }
# add-zsh-hook precmd -report-start-time
