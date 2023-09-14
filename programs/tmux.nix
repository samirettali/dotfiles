{ pkgs
, homeDirectory
, ...
}: {
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    extraConfig = ''
      bind Enter break-pane
      bind Space command-prompt "joinp -t:%%" # %% = prompt for window.pane [-V|H] # vert|hor split

      # Mantain path in new splits/panes
      unbind c
      bind c new-window -c '#{pane_current_path}'

      # Horizontal splitting
      unbind '"'
      bind - split-window -v -c '#{pane_current_path}'
      bind _ split-window -fv -c '#{pane_current_path}'

      # Verical splitting
      unbind %
      bind \\ split-window -h -c '#{pane_current_path}'
      bind | split-window -fh -c '#{pane_current_path}'
      bind r source-file ${homeDirectory}/.config/tmux/tmux.conf \; display-message "Config reloaded.."

      # Move windows
      bind -r '<' swap-window -d -t '{previous}'
      bind -r '>' swap-window -d -t '{next}'

      # Resize panes
      bind -r H resize-pane -L "5"
      bind -r J resize-pane -D "5"
      bind -r K resize-pane -U "5"
      bind -r L resize-pane -R "5"

      bind . attach -c "#{pane_current_path}"  # Set tmux root to current directory
      bind l next-layout
      bind b choose-tree
      bind z resize-pane -Z

      # Repeat command in last selected split/window
      bind b select-pane -t 3 \; send-keys Up C-m \; last-pane
      bind y select-window -t 2 \; send-keys Up C-m \;

      # Toggle between last active windows
      bind C-a last-window

      set -g renumber-windows on

      # Theme
      set -g status-justify left
      set -g status-style "bg=colour234 bold"
      
      set -g status-left "#S "
      set -g status-left-style "fg=red"
      set -g status-left-length 20
      
      set -g status-right "$USER@#H"
      set -g status-right-style "fg=green"
      # set -g status-right-length 20
      
      #  set -g window-status-style "fg=black"
      set -g window-status-format " #I:#W "
      set -g window-status-style "fg=#858585"
      set -g window-status-current-style "fg=yellow"
      set -g window-status-current-format " #I:#W "
      set -g window-status-separator " "
      
      set -g pane-active-border-style "bold fg=#858585"
      set -g pane-border-style "fg=colour234"
    '';
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    newSession = true; # TODO test this
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
      {
        plugin = tmuxPlugins.vim-tmux-navigator;
      }
    ];
    prefix = "C-a";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "xterm-256color";
  };
}
