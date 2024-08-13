{ pkgs
, ...
}: {
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = builtins.readFile ../dotfiles/tmux.conf;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    newSession = true;
    plugins = with pkgs; [
      # {
      #   plugin = tmuxPlugins.resurrect;
      #   extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      # }
      # {
      #   plugin = tmuxPlugins.continuum;
      #   extraConfig = ''
      #     set -g @continuum-restore 'on'
      #     set -g @continuum-save-interval '60' # minutes
      #   '';
      # }
      {
        plugin = tmuxPlugins.vim-tmux-navigator;
      }
    ];
    prefix = "C-a";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "xterm-256color";
  };
}
