{pkgs, ...}: {
  programs.tmux = {
    aggressiveResize = true;
    enable = true;
    escapeTime = 0;
    historyLimit = 100000;
    extraConfig = builtins.readFile ../dotfiles/tmux.conf;
    keyMode = "vi";
    mouse = true;
    newSession = false;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      t-smart-tmux-session-manager
    ];
    shortcut = "a";
  };

  home.sessionPath = [
    "${pkgs.tmuxPlugins.t-smart-tmux-session-manager}/share/tmux-plugins/t-smart-tmux-session-manager/bin"
  ];
}
