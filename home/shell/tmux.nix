{pkgs, ...}: {
  programs.tmux = {
    aggressiveResize = true;
    enable = true;
    escapeTime = 0;
    # Read tmux.conf and concat default shell
    extraConfig =
      builtins.readFile ../dotfiles/tmux.conf
      + ''
        set-option -g default-shell ${pkgs.zsh}/bin/zsh
        set-option -g default-command ${pkgs.zsh}/bin/zsh
      '';
    historyLimit = 100000;
    keyMode = "vi";
    mouse = true;
    newSession = false;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      t-smart-tmux-session-manager
    ];
    shortcut = "a";
    shell = "${pkgs.zsh}/bin/zsh";
  };

  home.sessionPath = [
    "${pkgs.tmuxPlugins.t-smart-tmux-session-manager}/share/tmux-plugins/t-smart-tmux-session-manager/bin"
  ];
}
