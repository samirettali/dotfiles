{ pkgs
, nixpkgs
, ...
}:
let
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
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Dracula'
      '';
  };

  linux-packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    cliphist
    bemenu
    wbg
    wdisplays
    xorg.xrdb
    hyprpicker
    wlprop
    networkmanagerapplet

    pamixer
    trash-cli
    p7zip
    unzip

    dbus-sway-environment
    configure-gtk
    xdg-utils

    firefox-wayland
    zathura
    cinnamon.nemo
    ffmpegthumbnailer
    webp-pixbuf-loader
    pavucontrol
    swayimg

    yubikey-personalization-gui
    neovim-nightly # MacOS build is broken
  ];

  mac-packages = with pkgs; [
    darwin.apple_sdk.frameworks.SystemConfiguration
    coreutils
  ];

  desktop-packages = with pkgs; [
    wezterm
    keepassxc
    vscode
    spotify
    qbittorrent
    yubikey-manager
  ];

  cli-packages = with pkgs; [
    unixtools.xxd
    tmux
    zellij
    entr
    tree
    jq
    htop
    lazygit
    lazydocker
    fd
    moreutils
    ranger
    tmuxinator
    espanso
    iredis
    pgcli
    ncdu
    ngrok
    mprocs
    trash-cli
    p7zip
    unzip
    diskus
    yazi
  ];

  work-packages = with pkgs; [
    awscli2
  ];

  dev-packages = with pkgs; [
    pkgs.tree-sitter
    lua-language-server
    rnix-lsp
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
    libiconv
    pkg-config
    zig
    zls
    jdk17
    ast-grep
    gnuplot
    bun
    python312
  ];

  rust-packages = with pkgs; [
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
    cargo-shuttle
    trunk
    sqlx-cli
    findomain
    nmap
    naabu
    ffuf
    amass
  ];

  bounty-packages = with pkgs; [
    dnsx
    httpx
  ];
in
{
  home.packages =
    desktop-packages
    ++ cli-packages
    ++ dev-packages
    ++ rust-packages
    ++ (nixpkgs.lib.optionals pkgs.stdenv.isLinux linux-packages)
    ++ (nixpkgs.lib.optionals pkgs.stdenv.isDarwin mac-packages)
    ++ (nixpkgs.lib.optionals pkgs.stdenv.isDarwin work-packages);
}
