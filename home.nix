{ config, pkgs, lib, dwl-source, ... }:

{
  imports = [
    ./user/zsh.nix
    ./user/gtk.nix
    ./user/fzf.nix
    ./user/git.nix
    # ./user/fonts.nix
  ];

  # (pkgs.writeShellScriptBin "my-hello" ''
  #   echo "Hello, ${config.home.username}!"
  # '')

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  # };

  home.stateVersion = "23.11";
  home.username = "samir";
  home.homeDirectory = "/home/samir";

  # nixpkgs.overlays = [
    # (import "${fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz"}/overlay.nix")
  # ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "ngrok"
    "vscode"
    "spotify"
  ];

  home.packages = with pkgs; [
    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    spotify
    # libnotify
    swayfx
    mako
    waybar
    # swaylock
    grim
    slurp
    kanshi
    wl-clipboard
    cliphist
    bemenu
    # wlprop
    tigervnc
    dwl
    wbg
    somebar
    foot
    wdisplays

    # desktop apps
    alacritty
    firefox-wayland
    keepassxc
    vscode
    kitty
    wezterm

    # neovim
    neovim-nightly

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

    pkgs.tree-sitter
    pkgs.networkmanagerapplet

    mpv
    zathura
    cinnamon.nemo
    ffmpegthumbnailer
    # xfce.tumbler
    webp-pixbuf-loader
    pavucontrol
    sxiv

    pamixer
    trashy
    p7zip
    unzip

    ngrok

    docker-compose

    lua-language-server
    nodePackages.vscode-langservers-extracted
    nixd

    # python3
    # pipenv
    nodejs

    go
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools
    gcc

    zig
    zls

    # ocaml
    ocaml
    # ocamlPackages.findlib
    ocamlPackages.utop
    ocamlPackages.ocamlformat
    dune_3
    nodePackages.ocaml-language-server

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

  nixpkgs.overlays = [
    (
      final: prev:
        {
          dwl = prev.dwl.override { conf = ./dwl-config.h; };
        }
    )
      (self: super: {
      dwl = super.dwl.overrideAttrs (oldAttrs: rec {
        src = dwl-source;
        patches = [
          ./dwl-patches/vanitygaps.patch
          ./dwl-patches/column.patch
          # ./dwl-patches/masteronright.patch
          # ./dwl-patches/autostart.patch
        ];
      });
    })
    # (import (builtins.fetchTarball {
    #   url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    # }))
  ];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

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
