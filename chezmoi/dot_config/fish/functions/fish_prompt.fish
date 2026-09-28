function fish_prompt
    # Select symbol
    set -l symbol '$ '
    if fish_is_root_user
        set symbol '# '
    end

    # Show user@host if connected via SSH
    set -l ssh
    if set -q SSH_CLIENT || set -q SSH_TTY
        set ssh (set_color -o blue) $USER '@' (hostname) (set_color -o normal) ":" (set_color normal)
    end

    set -l pwd (set_color -o blue) (prompt_pwd) (set_color normal)
    set -l bg_jobs (jobs -p)
    set -l bg_marker
    if test (count $bg_jobs) -gt 0
        set bg_marker (set_color -o yellow)'*'(set_color normal)
    end
    set -l symbol (set_color -o red) $symbol (set_color normal)

    set -l nix_shell_info
    if test -n "$IN_NIX_SHELL"
        set nix_shell_info "<nix-shell> "
    end

    printf '%s' (string join "" -- $ssh $nix_shell_info $pwd $bg_marker $symbol)
end
