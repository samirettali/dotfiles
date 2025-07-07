{
  lib,
  pkgs,
  ...
}: let
  iredisPkgs =
    import (builtins.fetchGit {
      name = "iredis115";
      url = "https://github.com/NixOS/nixpkgs/";
      ref = "refs/heads/nixpkgs-unstable";
      rev = "3e2cf88148e732abc1d259286123e06a9d8c964a";
    }) {
      system = pkgs.system;
    };

  iredis115 = iredisPkgs.iredis;
in {
  imports = [
    ./fish.nix
    ./git.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./llm.nix
    ./pass.nix
    ./tmux.nix
    ./zsh.nix
    ./opencode.nix # TODO: wait for nixpkgs
  ];

  home.packages = with pkgs; [
    bat
    # bombardier # http load testing
    broot
    codex
    # ctop # docket container monitoring
    curl
    difftastic
    diskus
    fd
    fx
    gemini-cli
    gh
    gnused
    # gping # graphical ping
    graphviz
    gum
    hexyl # hex viewer
    # hto
    # httptap
    hwatch # watch alternative with diff snapshots
    iredis115 # TODO: upstream is broken
    jq
    jqp
    kaf
    kcat
    lazysql
    libqalculate
    # lla # modern ls
    # lnav # log navigation
    moreutils
    # mprocs # multiple processes
    ncdu
    ngrok # tunneling
    p7zip
    pgcli
    plumber
    repomix
    ripgrep
    rlwrap
    # scc # count lines of code
    sesh # TODO: this is slow
    sqlite
    # superfile
    # tabview # csv viewer, maybe keep visidata
    tldr
    tree
    uutils-coreutils-noprefix
    unzip
    # vegeta # http load testing
    viddy # watch alternative with diff (not snapshots)
    visidata
    vi-mongo # mongodb cli
    watchexec # watch folder for changes and execute command
    wuzz
    xan # csv processing
    yazi # file manager
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
    fzf.enable = true;
    neovim = {
      enable = lib.mkDefault true;
      package = pkgs.neovim;
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
