{pkgs, ...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit =
      /*
      fish
      */
      ''
        set fish_greeting

        set fish_color_command green
        set fish_color_valid_path normal

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

            printf (string join "" -- $ssh $nix_shell_info $pwd $symbol)
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
      '';
    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];
  };
  home.packages = with pkgs; [
    grc
  ];
}
