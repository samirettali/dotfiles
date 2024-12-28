set fish_greeting

set fish_color_command green
set fish_color_valid_path normal

set -g fish_key_bindings fish_vi_key_bindings
set -g fish_key_bindings fish_hybrid_key_bindings

function fish_mode_prompt
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

function fish_right_prompt
    set_color -o brmagenta
    printf (fish_git_prompt "[%s]")
    set_color normal
end
