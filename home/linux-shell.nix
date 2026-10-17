# The shell of an Ubuntu host where home-manager owns only the user profile
# (andromeda, orion): bash as Ubuntu set it up, reached over SSH from Ghostty.
{pkgs, ...}: {
  # The Ubuntu side of home-manager; among other things every interactive
  # shell, not only a login one, loads the session variables.
  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      historySize = 100000;
      historyFileSize = 100000;
      historyControl = ["ignoreboth"];

      # rbw puts its socket under XDG_RUNTIME_DIR and falls back to $TMPDIR, which
      # `nix develop` rewrites per shell: without this every devshell got its own
      # agent, and a locked one hung `rbw get` in direnv on cd. systemd only
      # exports the variable for login sessions.
      bashrcExtra = ''
        if [ -z "$XDG_RUNTIME_DIR" ] && [ -d "/run/user/$(id -u)" ]; then
            export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        fi
      '';

      # Ubuntu's stock prompt and colors, which the hand-kept .bashrc had.
      initExtra = ''
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      '';

      shellAliases = {
        ls = "ls --color=auto";
        grep = "grep --color=auto";
      };
    };
  };

  home.packages = [pkgs.ghostty.terminfo];

  # genericLinux sets TERMINFO_DIRS only for systemd, which SSH
  # shells never read; ncurses always looks in ~/.terminfo.
  home.file.".terminfo".source = "${pkgs.ghostty.terminfo}/share/terminfo";
}
