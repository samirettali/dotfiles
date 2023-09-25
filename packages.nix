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
    bemenu
    cinnamon.nemo
    cliphist
    configure-gtk
    dbus-sway-environment
    ffmpegthumbnailer
    firefox-wayland
    grim
    hyprpicker
    j4-dmenu-desktop
    networkmanagerapplet
    p7zip
    pamixer
    pavucontrol
    slurp
    swayimg
    trash-cli
    unzip
    wbg
    wdisplays
    webp-pixbuf-loader
    wl-clipboard
    wlprop
    xdg-utils
    xorg.xrdb
    zathura
  ];

  mac-packages = with pkgs; [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  desktop-packages = with pkgs; [
    keepassxc
    qbittorrent
    spotify
    vscode
    wezterm
    yubikey-manager
    yubikey-personalization-gui
  ];

  cli-packages = with pkgs; [
    direnv
    diskus
    entr
    espanso
    fd
    htop
    iredis
    jq
    lazydocker
    lazygit
    moreutils
    mprocs
    ncdu
    ngrok
    p7zip
    pgcli
    tmux
    tmuxinator
    trash-cli
    tree
    ueberzugpp
    unixtools.xxd
    unzip
    yazi
    zellij
  ];

  dev-packages = with pkgs; [
    ast-grep
    bun
    cmake
    gcc
    gnumake
    gnuplot
    go
    golangci-lint
    golangci-lint-langserver
    gopls
    gotools
    jdk17
    libiconv
    lua-language-server
    neovim-nightly
    nodejs
    openssl
    pkg-config
    pkgs.tree-sitter
    python312
    rnix-lsp
    zig
    zls
  ] ++ (nixpkgs.lib.optionals pkgs.stdenv.isLinux [ docker-compose ]);

  rust-packages = with pkgs;
    [
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
      amass
      bunyan-rs
      cargo-shuttle
      cargo-watch
      ffuf
      findomain
      naabu
      nmap
      rust-analyzer-nightly
      sqlx-cli
      trunk
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
    ++ (nixpkgs.lib.optionals pkgs.stdenv.isDarwin mac-packages);
}
