{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./zsh.nix
    ./fish.nix
    ./tmux.nix
    ./pass.nix
    ./fzf.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    # httptap
    age
    bat
    bombardier
    broot
    curl
    diskus
    fd
    fx
    gh
    graphviz
    hexyl
    difftastic
    htop
    hwatch
    iredis
    jq
    kaf
    kcat
    lazydocker
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
    ripgrep
    scc
    sesh
    sqlite
    superfile
    tabview
    tldr
    tmux
    trash-cli
    tree
    unzip
    viddy
    visidata
    watchexec
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
    neovim = {
      enable = lib.mkDefault true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
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
