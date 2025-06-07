set fish_greeting

set fish_color_command green
set fish_color_valid_path normal

set -g fish_key_bindings fish_vi_key_bindings
set -g fish_key_bindings fish_hybrid_key_bindings

# TODO: this is not working
# bind \cz fg

function fish_mode_prompt
end

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
    set -l symbol (set_color -o red) $symbol (set_color normal)

    set -l nix_shell_info
    if test -n "$IN_NIX_SHELL"
        set nix_shell_info "<nix-shell> "
    end

    printf (string join '' -- $ssh $nix_shell_info $pwd $symbol)
end

function fish_right_prompt
    # Show last status code if != 0
    set -l last_status $status

    set -l stat
    if test $last_status -ne 0
        set stat (set_color -o bryellow)"($last_status)"(set_color normal)
    end

    # Git prompt
    set -l gp (set_color -o brmagenta)(fish_git_prompt "[%s]")(set_color normal)


    # Duration
    set -l d $CMD_DURATION
    set -l second 1000
    set -l minute (math 60 \* $second)
    set -l hour (math $minute \* 60)
    set -l s (math -s0 $d / $second)
    set -l m (math -s0 $d / $minute)
    set -l h (math -s0 $d / $hour)
    set -l duration

    if test $h -gt 0
        set h (math -s2 $d / $hour)
        set duration $h'h'
    else if test $m -gt 0
        set m (math -s2 $d / $minute)
        set duration $m'm'
    else if test $s -gt 0
        set s (math -s2 $d / $second)
        set duration $s's'
    else
        set duration $d'ms'
    end

    set duration (set_color -id white)$duration(set_color normal)

    printf (string join ' ' -- $duration $stat $gp)
end

function unexpand-home-tilde
    cat - | string replace $HOME '~'
end

function clip
    echo -n $argv | unexpand-home-tilde | fish_clipboard_copy
end

function default --argument val default
    if not string-empty $val
        echo $val
    else
        echo $default
    end
end

function mc --argument dir
    mkdir -p -- $dir
    and cd -- $dir
end

function bak --argument filename
    cp -r $filename $filename.bak
end

function string-empty --argument val
    test "$val" = ''
end

function trim-trailing-slash
    read str
    string replace -r '/$' '' -- $str
end

function is-symlink --argument file --argument extra
    if not string-empty $extra
        echo 'is-symlink: too many arguments' >&2
        return 1
    end
    test -L (echo $file | trim-trailing-slash)
end

function move
    set from $argv[1]
    if is-symlink $from; and string match --quiet --regex --entire '/$' $from
        echo move: `from` argument '"'$from'"' is a symlink with a trailing slash.
        echo move: to rename a symlink, remove the trailing slash from the argument.
        return 1
    end
    mv -i $argv
end

function move-last-download
    set destination (default $argv[1] .)
    set file_name (ls -t -A ~/Downloads/ | head -1)
    move ~/Downloads/$file_name $destination
    echo $file_name
end

function coln
    awk '{print $'$argv[1]'}'
end

function row --argument index
    sed -n "$index p"
end

function skip-lines --argument n
    tail +(math 1 + $n)
end

function take --argument number
    head -$number
end

function word-count
    wc -w | string trim
end

function line-count
    wc -l | string trim
end

function char-count
    wc -c | string trim
end

function readpass --argument var
    read --silent localvar
    export $var=$localvar
end

function gcd --argument repo
    git clone $repo
    # split at / and take last element
    set repo_name (string split / $repo | tail -1)
    and cd $repo_name
end

function dcd
    if string-empty $argv[1]
        docker-compose down
    else
        docker-compose -f $argv[1] down
    end
end

function dcu
    if string-empty $argv[1]
        docker-compose up -d
    else
        docker-compose -f $argv[1] up -d
    end
end
