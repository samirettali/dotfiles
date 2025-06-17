{
  lib,
  pkgs,
  inputs,
  ...
}: let
  codex = pkgs.callPackage ./codex.nix {};
  opencode = pkgs.callPackage ./derivations/opencode.nix {};
in {
  imports = [
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./llm.nix
    ./pass.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    age
    bat
    bombardier
    broot
    codex
    ctop
    curl
    difftastic
    diskus
    fd
    fx
    gh
    gping
    graphviz
    gum
    hexyl
    htop
    httptap
    hwatch
    iredis
    jq
    jqp
    kaf
    kcat
    lazysql
    libqalculate
    lla
    lnav
    moreutils
    mprocs
    ncdu
    ngrok
    opencode
    p7zip
    pgcli
    plumber
    repomix
    ripgrep
    rlwrap
    scc
    sesh
    sqlite
    superfile
    tabview
    tldr
    tmux
    tree
    unzip
    vegeta
    viddy
    visidata
    watchexec
    wuzz
    xan
    yazi
    yt-dlp
    yubikey-manager
  ];

  programs = {
    btop = {
      enable = true;
      settings = {
        color_theme = "TTY";
        vim_keys = true;
      };
    };
    direnv.enable = true;
    neovim = {
      enable = lib.mkDefault true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    ripgrep = {
      enable = lib.mkDefault true;
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--glob=!node_modules/*"
        "--colors=line:none"
        "--colors=line:style:bold"
        "--hidden"
        "--smart-case"
      ];
    };
    zoxide.enable = true;
  };
}
