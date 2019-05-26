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

function () {
    # Check for tmux by looking at $TERM, because $TMUX won't be propagated to any
    # nested sudo shells but $TERM will.
    if [ -n "$TMUX" ] || [ -n "$SSH_CONNECTION" ]; then
        # In a a tmux session created in a non-root or root shell.
        local LVL=$SHLVL
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
    export PS1="%F{blue}${SSH_CONNECTION:+%n@%m}%f%B${SSSH_CONNECTION:+:}%b%F{blue}%B%1d%b%F{yellow}%B%(1j.*.)%(?..!)%b%f%B${SUFFIX}%b "
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
    echo "${${KEYMAP/vicmd/}/(main|viins)/}"
}

export RPS1='%F{red}$(vi_mode_prompt_info)%f $(git_super_status)'
