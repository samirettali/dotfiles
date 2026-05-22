{
  pkgs,
  samirettali-nur,
  ...
}: {
  imports = [
    ./ansible.nix
    ./btop.nix
    ./claude-code.nix
    ./direnv.nix
    ./fabric.nix
    ./fish.nix
    ./fzf.nix
    ./gemini-cli.nix
    ./gh.nix
    ./git-sync.nix
    ./git.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./neovim.nix
    ./nh.nix
    ./opencode.nix
    ./pi-coding-agent
    ./posting.nix
    ./ripgrep.nix
    ./scripts
    ./sesh.nix
    ./spotify-player.nix
    ./tmux.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    bitwarden-cli
    coreutils
    curl
    difftastic
    duf
    fd
    gnused
    hwatch
    iredis
    jq
    jqp
    kcat
    lazysql
    moreutils
    ncdu
    ngrok
    p7zip
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.go-qo
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.tredis
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.hunk
    scc
    snitch
    sqlite
    tree
    unzip
    vi-mongo
    watchexec
    # yubikey-manager
    # repomix
    # amp-cli
    # bombardier # http load testing
    # broot
    # crush
    # ctop # docket container monitoring
    # github-copilot-cli
    # diskus
    # fx
    # gping # graphical ping
    # graphviz
    # gum
    # hexyl # hex viewer
    # hto
    # httptap
    # kaf
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
