{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.tmux;
in {
  programs.tmux = {
    enable = lib.mkDefault true;
    aggressiveResize = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    resizeAmount = 5;
    keyMode = "vi";
    mouse = true;
    focusEvents = true;
    shell = lib.getExe pkgs.fish;
    extraConfig = ''
      set -g extended-keys on
      # TODO
      # set -as terminal-features 'xterm*:extkeys'
      # set -as terminal-features ',*ghostty*:extkeys'
      set -g extended-keys-format csi-u

      bind -r -N "Move window to the left" \
        '<' swap-window -d -t '{previous}'

      bind -r -N "Move window to the right" \
        '>' swap-window -d -t '{next}'

      bind -N "Select the previous window" C-p select-window -p
      bind -N "Select the previous window" p select-window -p
      bind -N "Select the next window" C-n select-window -n
      bind -N "Select the next window" n select-window -n

      bind -N "Select pane to the left of the active pane" C-h select-pane -L
      bind -N "Select pane below the active pane" C-j select-pane -D
      bind -N "Select pane above the active pane" C-k select-pane -U
      bind -N "Select pane to the right of the active pane" C-l select-pane -R
      bind -N "Select pane to the left of the active pane" h select-pane -L
      bind -N "Select pane below the active pane" j select-pane -D
      bind -N "Select pane above the active pane" k select-pane -U
      bind -N "Select pane to the right of the active pane" l select-pane -R

      bind -r -N "Resize the pane left by ${toString cfg.resizeAmount}" \
        H resize-pane -L ${toString cfg.resizeAmount}

      bind -r -N "Resize the pane down by ${toString cfg.resizeAmount}" \
        J resize-pane -D ${toString cfg.resizeAmount}

      bind -r -N "Resize the pane up by ${toString cfg.resizeAmount}" \
        K resize-pane -U ${toString cfg.resizeAmount}

      bind -r -N "Resize the pane right by ${toString cfg.resizeAmount}" \
        L resize-pane -R ${toString cfg.resizeAmount}

      bind r source-file ~/.config/tmux/tmux.conf \; display " Config reloaded!"

      bind -N "Select last window" \
        tab last-window

      set -g renumber-windows on
      set -g allow-rename off

      # Theme
      set -g status-justify left
      set -g status-style "bg=default bold"

      set -g status-left " #S "
      set -g status-left-style "fg=green"
      set -g status-left-length 20

      set -g status-right ""
      set -g window-status-style "fg=#858585"
      set -g window-status-current-style "fg=white"

      set -g pane-active-border-style "bold fg=#858585"
      set -g pane-border-style "fg=colour234"
      set -g allow-passthrough on

      # TODO: is this still needed with ghostty?
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set-option -sa terminal-overrides ",xterm*:Tc"

      set -g message-style 'fg=yellow bg=black bold'
    '';
  };

  home.shellAliases = lib.mkIf cfg.enable {
    tl = "${lib.getExe cfg.package} ls";
  };
}
