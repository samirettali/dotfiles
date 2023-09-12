{
  pkgs,
  nixpkgs,
  ...
}: let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };

  linux-packages = with pkgs; [
    grim
    slurp
    kanshi
    wl-clipboard
    cliphist
    bemenu
    wbg
    wdisplays
    xorg.xrdb
    hyprpicker
    networkmanagerapplet

    pamixer
    trash-cli
    p7zip
    unzip

    dbus-sway-environment
    configure-gtk
    xdg-utils

    foot

    firefox-wayland
    mpv
    zathura
    cinnamon.nemo
    ffmpegthumbnailer
    webp-pixbuf-loader
    pavucontrol
    sxiv
  ];
  common-packages = with pkgs; [
    # desktop apps
    wezterm
    keepassxc
    # vscode
    # spotify
    qbittorrent

    # neovim-nightly
    neovim

    # cli tools
    direnv
    unixtools.xxd
    fzf
    tmux
    zellij
    entr
    tree
    jq
    htop
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
    # ngrok
    mprocs

    pkgs.tree-sitter

    trash-cli
    p7zip
    unzip

    lua-language-server
    nixd

    nodejs

    go
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools
    gcc
    gnumake
    cmake

    openssl
    pkg-config

    zig
    zls

    dnsx
    httpx

    # (fenix.combine [
    #   (fenix.complete.withComponents [
    #     "cargo"
    #     "clippy"
    #     "rust-src"
    #     "rustc"
    #     "rustfmt"
    #   ])
    #   fenix.targets.wasm32-unknown-unknown.latest.rust-std
    # ])
    # rust-analyzer-nightly
    # cargo-watch
    # cargo-shuttle
    # trunk
  ];
in {
  home.packages =
    common-packages
      ++ (nixpkgs.lib.optionals pkgs.stdenv.isLinux linux-packages);
}
