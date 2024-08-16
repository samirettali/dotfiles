# Git prompt
autoload -Uz vcs_info
precmd_vcs_info() {
    vcs_info
}

precmd_functions+=(precmd_vcs_info)
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{magenta}%B[%b]%%b%f'
zstyle ':vcs_info:*' enable git

# Prompt
function () {
    if [[ "$TERM_PROGRAM" == 'vscode' ]]; then
        local LVL=$(($SHLVL - 3))
    elif [[ -n "$TMUX" ]]; then
        local LVL=$(($SHLVL - 1))
    else
        # Simple terminal
        local LVL=$SHLVL
    fi

    if [[ $EUID -eq 0 ]]; then
        local SUFFIX=$(printf '\#%.0s' {1..$LVL})
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

## TODO do this only if gui
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

# keybindings
bindkey '^F' fzf-file-widget
bindkey '^ ' autosuggest-accept

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^x' edit-command-line

function fg-bg() {
    if [[ $#BUFFER -eq 0 ]]; then
        fg
    else
        zle push-input
    fi
}
zle -N fg-bg
bindkey '^Z' fg-bg

tmux_session_or_attach() {
    # Use the first argument as session name, or the current directory name if no argument is provided
    local session_name=${1:-$(basename "$PWD")}

    # Check if the tmux session exists, and attach to it; create a new one if it doesn't exist
    tmux has-session -t "$session_name" 2>/dev/null
    if [ $? != 0 ]; then
        tmux new-session -s "$session_name"
    else
        tmux attach-session -t "$session_name"
    fi
}

# Define the completion function
_tmux_session_or_attach_completions() {
    # Get the list of existing tmux sessions
    local sessions=$(tmux list-sessions -F "#S" 2>/dev/null)

    # Use COMPREPLY to provide the suggestions
    COMPREPLY=($(compgen -W "$sessions" -- "${COMP_WORDS[1]}"))
}

# Register the completion function with the custom function
complete -F _tmux_session_or_attach_completions tmux_session_or_attach

export PATH=~/.yarn/bin/:~/.bin:$PATH
# export PKG_CONFIG_PATH=${pkgs.openssl.dev}/lib/pkgconfig
