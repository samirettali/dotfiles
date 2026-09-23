{
  imports = [
    ./dotfiles.nix
    ./options.nix
    ./packages/dev/c.nix
    ./packages/dev/go.nix
    ./packages/dev/headless-browser.nix
    ./packages/dev/js.nix
    ./packages/dev/python.nix
    ./packages/shell
  ];

  dotfiles.programs = {
    ansible.enable = false;
    git-sync.enable = false;
  };

  programs.fish.enable = false;

  programs.bash = {
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

  home.sessionPath = ["$HOME/.local/bin"];
  home.sessionVariables.KIMI_MEMBERSHIP_LEVEL = "moderato";
}
