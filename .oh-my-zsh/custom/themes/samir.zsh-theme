# prompt

ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_SEPARATOR=""
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[yellow]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg_bold[red]%}%{✖●%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg_bold[blue]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{↓%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
RPROMPT_BASE='$(git_super_status)'
# RPROMPT_BASE='%F{red}$(vi_mode_prompt_info)%f $(git_super_status)'

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
