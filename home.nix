{ config, pkgs, lib, ... }:

{
  imports = [
    ./user/zsh.nix
    ./user/gtk.nix
    ./user/fzf.nix
    ./user/git.nix
    # ./user/fonts.nix
  ];

  # (pkgs.writeShellScriptBin "my-hello" ''
  # '')

  home.file = {
    ".config/wezterm/wezterm.lua".source = dotfiles/wezterm.lua;
    ".Xresources".source = dotfiles/Xresources;
    ".config/sway/config".source = dotfiles/sway_config;
    ".ackrc".source = dotfiles/ackrc;
    ".config/alacritty/alacritty.yml".source = dotfiles/alacritty.yml;
    ".ideavimrc".source = dotfiles/ideavimrc;
    ".config/waybar/config".source = dotfiles/waybar/config;
    ".config/waybar/style.css".source = dotfiles/waybar/style.css;
    ".config/foot/foot.ini".source = dotfiles/foot.ini;
    ".config/nvim" = { source = dotfiles/nvim; recursive = true; };

    # You can also set the file content immediately.
    ".tmux.conf".text = ''
# Remap prefix from 'C-b' to 'C-a'
unbind C-b
set-option -g prefix C-a

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

# Move windows
bind-key -r '<' swap-window -d -t '{previous}'
bind-key -r '>' swap-window -d -t '{next}'

# Resize panes
bind -r H resize-pane -L "5"
bind -r J resize-pane -D "5"
bind -r K resize-pane -U "5"
bind -r L resize-pane -R "5"

bind l next-layout

bind r source-file ~/.tmux.conf

# clear buffer
bind s clear-history

# change tmux root to current directory
unbind .
bind . attach -c "#{pane_current_path}"

unbind m
bind m command-prompt "move-window -t '%%'"

bind C-a last-window

# execute last command in last selected split
bind b select-pane -t 2 \; send-keys Up C-m \; last-pane
bind y select-window -t 2 \; send-keys Up C-m \;

# vim visual mode and copy
bind -T copy-mode-vi 'v' send -X begin-selection
bind -T copy-mode-vi 'y' send -X copy-selection-and-cancel

# move panes windows: <prefix> s, <prefix> j
bind j command-prompt -p "join pane from:"  "join-pane -s '%%'"
bind S command-prompt -p "send pane to:"  "join-pane -t '%%'"

bind Enter break-pane
bind Space command-prompt "joinp -t:%%" # %% = prompt for window.pane [-V|H] # vert|hor split

# settings
set set-clipboard on
set -g base-index 1
set -s escape-time 0
set -g default-terminal "xterm-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
setw -g pane-base-index 1
setw -g mode-keys vi
set -g renumber-windows on
set-option -g allow-rename off
set-option -g set-titles on
set-option -g set-titles-string "#{session_name} - #{host}"
set-option -g default-shell ${pkgs.zsh}/bin/zsh
set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

# Settings from tmux-sensible
set -g history-limit 50000
set -g display-time 4000
set -g mouse on
# set -g default-command "reattach-to-user-namespace -l $SHELL" # test if needed
set -g focus-events on
setw -g aggressive-resize on

# Disable prefix with F12 to use nested tmux inside ssh session
bind -T root F12  \
  set prefix None \;\
  set key-table off \;\
  set status-right "OFF" \;\
  if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
  refresh-client -S \;\

bind -T off F12 \
  set -u prefix \;\
  set -u status-right \;\
  set -u key-table \;\
  refresh-client -S

# Theme
# setw -g window-active-style fg=white,bg=black
# setw -g window-style fg=white,bg=black

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

# Remember to check every now and then the repo if something changed.
# Only way to get rid of TPM.
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
bind-key -T copy-mode-vi 'C-\' select-pane -l

bind-key s choose-session'';
  };

  home.stateVersion = "23.11";
  home.username = "samir";
  home.homeDirectory = "/home/samir";

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "ngrok"
    "vscode"
    "spotify"
  ];

  home.packages = with pkgs; [
    swayfx
    mako
    waybar
    grim
    slurp
    kanshi
    wl-clipboard
    cliphist
    bemenu
    wbg
    wdisplays

    foot

    # desktop apps
    wezterm
    keepassxc
    vscode
    spotify

    firefox-wayland
    mpv
    zathura
    cinnamon.nemo
    ffmpegthumbnailer
    webp-pixbuf-loader
    pavucontrol
    sxiv

    neovim-nightly

    # cli tools
    direnv
    unixtools.xxd
    fzf
    tmux
    zellij
    entr
    tree
    jq
    lazygit
    lazydocker
    fd
    ripgrep
    moreutils
    ranger
    tmuxinator
    espanso
    iredis
    pgcli
    ncdu
    ngrok

    pkgs.tree-sitter
    pkgs.networkmanagerapplet

    pamixer
    trash-cli
    p7zip
    unzip

    docker-compose

    lua-language-server
    nixd

    nodejs

    go
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools
    gcc

    zig
    zls

    dnsx
    httpx

    (fenix.combine [
      (fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      fenix.targets.wasm32-unknown-unknown.latest.rust-std
    ])
    rust-analyzer-nightly
    cargo-watch
    trunk
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    BEMENU_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  };

  programs =  {
    home-manager.enable = true;
  };

  # services = {
  #   mpris-proxy.enable = true;
  # }
}
