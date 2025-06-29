{
  lib,
  pkgs,
  ...
}: let
  codex = pkgs.callPackage ./codex.nix {};
  gemini-cli = pkgs.callPackage ./gemini-cli.nix {};
  gemini-cli-unbundled = gemini-cli.overrideAttrs (oldAttrs: {
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        echo "Removing bundled eslint from gemini-cli to prevent collision"
        rm -rf $out/lib/node_modules/eslint

        # Also remove the symlink that points to the now-deleted directory.
        # We use -f to prevent an error if the symlink doesn't exist for some reason.
        rm -f $out/lib/node_modules/.bin/eslint
      '';
  });

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
    gnused
    gping
    graphviz
    gum
    hexyl
    htop
    httptap
    hwatch
    iredis115 # TODO: upstream is broken
    jq
    jqp
    kaf
    gemini-cli-unbundled # TODO: wait for nixpkgs
    kcat
    lazysql
    libqalculate
    lla
    lnav
    moreutils
    mprocs
    ncdu
    ngrok
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
