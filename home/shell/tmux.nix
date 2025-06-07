{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.tmux = {
    aggressiveResize = true;
    enable = true;
    escapeTime = 0;
    extraConfig = builtins.readFile ../dotfiles/tmux.conf;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    newSession = false;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      t-smart-tmux-session-manager
    ];
    shortcut = "a";
  };

  # TODO: check if this is needed
  home.sessionPath = [
    "${pkgs.tmuxPlugins.t-smart-tmux-session-manager}/share/tmux-plugins/t-smart-tmux-session-manager/bin"
  ];

  programs.fish.shellAliases = lib.mkIf config.programs.tmux.enable {
    tl = "${lib.getExe pkgs.tmux} ls";
  };

  programs.zsh.shellAliases = lib.mkIf config.programs.tmux.enable {
    tl = "${lib.getExe pkgs.tmux} ls";
  };
}
