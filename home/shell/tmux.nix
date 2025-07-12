{
  config,
  lib,
  pkgs,
  tmux-rs,
  ...
}: let
  cfg = config.programs.tmux;
in {
  home.packages = lib.mkIf cfg.enable [
    tmux-rs.packages.${pkgs.system}.default
  ];

  programs.tmux = {
    enable = false;
    aggressiveResize = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    resizeAmount = 5;
    keyMode = "vi";
    mouse = true;
    focusEvents = true;
    shell = lib.getExe pkgs.fish;
    shortcut = "a";
    # bind space command-prompt "joinp -s:%%" # %% = prompt for window.pane [-V|H] # vert|hor split
    extraConfig = ''
      unbind c
      bind -N "Create new window with the current path" \
        c new-window -c '#{pane_current_path}'

      bind -N "Create new window with the current path" \
        C-c new-window -c '#{pane_current_path}'

      bind -r -N "Move window to the left" \
        '<' swap-window -d -t '{previous}'

      bind -r -N "Move window to the right" \
        '>' swap-window -d -t '{next}'

      bind -N "Horizontal split" \
        s split-window -v -c '#{pane_current_path}'

      bind -N "Full horizontal split" \
        S split-window -fv -c '#{pane_current_path}'

      bind -N "Vertical split" \
        v split-window -h -c '#{pane_current_path}'

      bind -N "Full vertical split" \
        V split-window -fh -c '#{pane_current_path}'

      bind -r -N "Select the previous window" C-p select-window -p
      bind -r -N "Select the previous window" p select-window -p
      bind -r -N "Select the next window" C-n select-window -n
      bind -r -N "Select the next window" n select-window -n

      bind -r -N "Select pane to the left of the active pane" C-h select-pane -L
      bind -r -N "Select pane below the active pane" C-j select-pane -D
      bind -r -N "Select pane above the active pane" C-k select-pane -U
      bind -r -N "Select pane to the right of the active pane" C-l select-pane -R
      bind -r -N "Select pane to the left of the active pane" h select-pane -L
      bind -r -N "Select pane below the active pane" j select-pane -D
      bind -r -N "Select pane above the active pane" k select-pane -U
      bind -r -N "Select pane to the right of the active pane" l select-pane -R

      bind -r -N "Resize the pane left by ${toString cfg.resizeAmount}" \
        H resize-pane -L ${toString cfg.resizeAmount}

      bind -r -N "Resize the pane down by ${toString cfg.resizeAmount}" \
        J resize-pane -D ${toString cfg.resizeAmount}

      bind -r -N "Resize the pane up by ${toString cfg.resizeAmount}" \
        K resize-pane -U ${toString cfg.resizeAmount}

      bind -r -N "Resize the pane right by ${toString cfg.resizeAmount}" \
        L resize-pane -R ${toString cfg.resizeAmount}

      # repeat command in last selected pane
      bind -N "Repeat command in last pane" \
        b last-pane \; send-keys Up C-m \; last-pane

      bind -N "Select last window"\
        enter last-window

      bind -N "Open lazygit in a popup" \
        C-g display-popup -E -d "#{pane_current_path}" -xC -yC -w 80% -h 75% "${lib.getExe pkgs.lazygit}"

      set -g renumber-windows on
      set -g allow-rename off

      # Theme
      set -g status-justify left
      set -g status-style "bg=black bold"

      set -g status-left " #S "
      set -g status-left-style "fg=green"
      set -g status-left-length 20

      set -g status-right ""
      set -g window-status-style "fg=#858585"
      set -g window-status-current-style "fg=white"

      set -g pane-active-border-style "bold fg=#858585"
      # set -g pane-border-style "fg=colour234"
      set -g allow-passthrough on

      # TODO: is this still needed with ghostty?
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      bind-key "t" display-popup -E -w 40% "${lib.getExe pkgs.sesh} connect \"$(
        ${lib.getExe pkgs.sesh} list -i | ${lib.getExe pkgs.gum} filter --limit 1 --no-sort --fuzzy --placeholder ''' --height 10
      )\""
    '';
  };

  programs.fish.shellAliases = lib.mkIf cfg.enable {
    tl = "${lib.getExe cfg.package} ls";
  };

  programs.zsh.shellAliases = lib.mkIf cfg.enable {
    tl = "${lib.getExe cfg.package} ls";
  };
}
