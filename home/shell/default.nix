{
  pkgs,
  samirettali-nur,
  ...
}: {
  imports = [
    ./fish.nix
    ./bat.nix
    ./btop.nix
    ./claude-code.nix
    ./gemini-cli.nix
    ./direnv.nix
    ./fabric.nix
    ./fzf.nix
    ./git.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./llm.nix
    ./neovim.nix
    ./opencode.nix
    ./pass.nix
    ./ripgrep.nix
    ./posting.nix
    ./tmux.nix
    ./zellij.nix
    ./zsh.nix
    ./zoxide.nix
    ./scripts
  ];

  home.packages = with pkgs; [
    coreutils
    curl
    difftastic
    fd
    gh
    github-copilot-cli
    gnused
    hwatch
    iredis
    jq
    jqp
    lazysql
    moreutils
    ncdu
    ngrok
    p7zip
    repomix
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.tredis
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.go-qo
    scc
    snitch
    sqlite
    tree
    unzip
    vi-mongo
    watchexec
    yubikey-manager
    # amp-cli
    # bombardier # http load testing
    # broot
    # crush
    # ctop # docket container monitoring
    # diskus
    # fx
    # gping # graphical ping
    # graphviz
    # gum
    # hexyl # hex viewer
    # hto
    # httptap
    # kaf
    # kcat # TODO: upstream is broken
    # libqalculate
    # lnav # log navigation
    # mprocs # multiple processes
    # pgcli
    # plumber
    # rlwrap
    # sqlit-tui
    # superfile
    # tabview # csv viewer, maybe keep visidata
    # tldr
    # vegeta # http load testing
    # viddy # watch alternative with diff (not snapshots)
    # visidata # TODO: the derivation takes ~2.5 GB
    # witr # find out why processes are running
    # wuzz
    # xan # csv processing
    # yazi # file manager
    # yt-dlp # TODO: upstream is broken
  ];
}
