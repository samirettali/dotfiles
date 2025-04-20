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
    age
    bat
    bombardier
    broot
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
    ijq
    iredis
    jq
    kaf
    kcat
    lazydocker
    libqalculate
    lazysql
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
    rlwrap
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
    vegeta
    viddy
    watchexec
    xan
    yazi
    yt-dlp
    yubikey-manager
    visidata

    # TODO: this is broken
    # (python3.withPackages (ps: [
    #   ps.llm
    #   ps.llm-ollama
    # ]))
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
