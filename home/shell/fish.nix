{pkgs, ...}: {
  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
      fish_mode_prompt = "";
      fish_prompt =
        /*
        fish
        */
        ''
          set -l last_status $status # this has to be here otherwise $status will be overridden by any command

          # Select symbol
          set -l symbol '$ '
          if fish_is_root_user
          	set symbol '# '
          end

          set -l stat
          if test $last_status -ne 0
          	set stat (set_color -o bryellow)"($last_status) "(set_color normal)
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

          printf (string join "" -- $stat $ssh $nix_shell_info $pwd $symbol)
        '';
    };
    interactiveShellInit =
      /*
      fish
      */
      ''
        set fish_color_command green
        set fish_color_valid_path normal

        set -g fish_key_bindings fish_hybrid_key_bindings

        # TODO: this is not working
        # bind \cz fg
      '';
  };
}
