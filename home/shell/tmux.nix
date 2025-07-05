{
  config,
  lib,
  pkgs,
  samirettali-nur,
  ...
}: let
  tmux-rs = samirettali-nur.packages.${pkgs.system}.tmux-rs;
in {
  home.packages = [tmux-rs];

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
    ];
    shortcut = "a";
  };

  programs.fish.shellAliases = lib.mkIf config.programs.tmux.enable {
    tl = "${lib.getExe pkgs.tmux} ls";
  };

  programs.zsh.shellAliases = lib.mkIf config.programs.tmux.enable {
    tl = "${lib.getExe pkgs.tmux} ls";
  };
}
