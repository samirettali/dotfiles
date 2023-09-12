{ username, homeDirectory, stateVersion, pkgs, nixpkgs, profile, home-manager, ... }:
{
  imports = [
    ./dotfiles.nix
    ./user/zsh.nix
    ./user/fzf.nix
    ./user/git.nix
  ]
  ++ nixpkgs.lib.optionals pkgs.stdenv.isLinux [
    (import ./linux.nix { inherit home-manager pkgs homeDirectory; })
  ];

  home.stateVersion = "${stateVersion}";
  home.username = "${username}";
  home.homeDirectory = "${homeDirectory}";

  home.sessionVariables = {
    EDITOR = "nvim";
    RIPGREP_CONFIG_PATH = "${homeDirectory}/.ripgreprc";
  };

  programs =  {
    home-manager.enable = true;
  };

  # (pkgs.writeShellScriptBin "my-hello" ''
  # '')

  home.packages = with pkgs; [
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
}
