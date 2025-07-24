{pkgs, ...}: let
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
    ./bat.nix
    ./btop.nix
    ./claude-code.nix
    ./direnv.nix
    ./fzf.nix
    ./git.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./llm.nix
    ./neovim.nix
    ./opencode.nix
    ./pass.nix
    ./ripgrep.nix
    ./television.nix
    ./tmux.nix
    ./zellij.nix
    ./zsh.nix
    ./zoxide.nix
    ./scripts
  ];

  home.packages = with pkgs; [
    # bombardier # http load testing
    # broot
    # codex
    # ctop # docket container monitoring
    curl
    # difftastic
    # diskus
    fd
    # fx
    gemini-cli
    gh
    gnused
    # gping # graphical ping
    # graphviz
    # gum
    # hexyl # hex viewer
    # hto
    # httptap
    hwatch # watch alternative with diff snapshots
    iredis115 # TODO: upstream is broken
    jq
    jqp
    # kaf
    kcat
    lazysql
    # libqalculate
    # lla # modern ls
    # lnav # log navigation
    moreutils # TODO: replace with go-moreutils or rewrite
    # mprocs # multiple processes
    ncdu
    ngrok # tunneling
    p7zip
    # pgcli
    # plumber
    repomix
    # rlwrap
    # scc # count lines of code
    sqlite
    # superfile
    # tabview # csv viewer, maybe keep visidata
    # tldr
    tree
    uutils-coreutils-noprefix
    unzip
    # vegeta # http load testing
    # viddy # watch alternative with diff (not snapshots)
    # visidata # TODO: the derivation takes ~2.5 GB
    vi-mongo # mongodb cli
    watchexec # watch folder for changes and execute command
    # wuzz
    # xan # csv processing
    # yazi # file manager
    yt-dlp
    yubikey-manager
  ];
}
