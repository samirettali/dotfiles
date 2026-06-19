{
  pkgs,
  nurPkgs,
  ...
}: {
  imports = [
    ./ansible.nix
    ./antigravity-cli.nix
    ./bat.nix
    ./btop.nix
    ./claude-code.nix
    ./difftastic.nix
    ./direnv.nix
    ./fabric.nix
    ./fish.nix
    ./fzf.nix
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
    ./tealdeer.nix
    ./tmux.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    coreutils
    curl
    duf
    fd
    gnused
    hwatch
    # iredis
    jq
    jqp
    kcat
    lazysql
    moreutils
    ncdu
    ngrok
    p7zip
    nurPkgs.go-qo
    # nurPkgs.tredis
    nurPkgs.hunk
    nurPkgs.grok-cli
    scc
    snitch
    sqlite
    tree
    unzip
    vi-mongo
    watchexec
    # bitwarden-cli
    # ghui # TODO: upstream is broken
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
