function () {
    # Check for tmux by looking at $TERM, because $TMUX won't be propagated to any
    # nested sudo shells but $TERM will.
    local TMUXING=$([[ "$TERM" =~ "tmux" ]] && echo tmux)
    if [ -n "$TMUXING" -a -n "$TMUX" ]; then
        # In a a tmux session created in a non-root or root shell.
        local LVL=$(($SHLVL - 2))
    else
        # Either in a root shell created inside a non-root tmux session,
        # or not in a tmux session.
        local LVL=$(($SHLVL - 1))
    fi
    # Check if the current shell is being executed by root to append # or $
    # accordingly
    if [[ $EUID -eq 0 ]]; then
        local SUFFIX='%F{yellow}%n%f'$(printf '%%F{yellow}#%.0s%%f' {1..$LVL})
    else
        local SUFFIX=$(printf '%%F{red}$%.0s%%f' {1..$LVL})
    fi
    export PS1="%F{blue}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b%F{blue}%B%1d%b%F{yellow}%B%(1j.*.)%(?..!)%b%f%B${SUFFIX}%b "
}
export RPROMPT="\$(git_super_status) %F{blue}%~%b"
export SPROMPT="zsh: correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "
