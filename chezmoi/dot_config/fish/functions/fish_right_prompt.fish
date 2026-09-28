function fish_right_prompt
    set -l last_status $status
    if contains -- --final-rendering $argv
        return
    end

    # Show last status code if != 0

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
    set -l hour (math 60 \* $minute)
    set -l h (math -s0 $d / $hour)
    set -l m (math -s0 $d % $hour / $minute)
    set -l s (math -s0 $d % $minute / $second)
    set -l duration

    if test $h -gt 0
        set duration $h'h'$m'm'
    else if test $m -gt 0
        set duration $m'm'$s's'
    else if test $s -gt 0
        set duration (math -s2 $d / $second)'s'
    else
        set duration $d'ms'
    end

    set duration (set_color -d white)$duration(set_color normal)

    printf '%s' (string join ' ' -- $duration $stat $gp)
end
