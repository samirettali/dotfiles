set fish_greeting # Disable greeting

function fish_mode_prompt
end

set -g fish_key_bindings fish_vi_key_bindings
set -g fish_key_bindings fish_hybrid_key_bindings

function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t -- $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function bind_dollar
    switch (commandline -t)[-1]
        case "!"
            commandline -f backward-delete-char history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

function fish_user_key_bindings
    bind ! bind_bang
    bind '$' bind_dollar
end

function fish_prompt
    set -l symbol '$ '
    if fish_is_root_user
        set symbol '# '
    end

    set_color -o blue
    if set -q SSH_CLIENT || set -q SSH_TTY
        printf '%s@%s' $USER (hostname)
        set_color -o normal
        printf ':'
        set_color -o blue
    end
    echo -n (prompt_pwd)

    set_color -o red
    echo -n $symbol

    set_color normal
end
