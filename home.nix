{ config, pkgs, lib, ... }:

{
  imports = [
    ./user/zsh.nix
    ./user/gtk.nix
    ./user/fzf.nix
    ./user/git.nix
  ];

  home.stateVersion = "23.11";
  home.username = "samir";
  home.homeDirectory = "/home/samir";

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

  services = {
    mpris-proxy.enable = true;
  };

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
    ".tmux.conf" = dotfiles/tmux.conf;
    ".config/nvim" = { source = dotfiles/nvim; recursive = true; };
  };

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
}
