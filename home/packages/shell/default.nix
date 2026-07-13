{
  pkgs,
  lib,
  nurPkgs,
  ...
}: {
  imports = [
    ./ansible.nix
    ./bat.nix
    ./btop.nix
    ./difftastic.nix
    ./direnv.nix
    ./fd.nix
    ./fish.nix
    ./fzf.nix
    ./gh.nix
    ./git-sync.nix
    ./git.nix
    ./hwatch.nix
    ./jq.nix
    ./jqp.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./lazysql.nix
    ./neovim.nix
    ./nh.nix
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

  dotfiles.programs = {
    ansible.enable = lib.mkDefault true;
    git-sync.enable = lib.mkDefault true;
  };

  home.packages = with pkgs; [
    coreutils
    curl
    gnused
    iredis
    kcat
    moreutils
    ncdu
    ngrok
    p7zip
    nurPkgs.go-qo
    nurPkgs.hunk
    scc
    snitch
    sqlite
    tree
    unzip
    watchexec
    # nurPkgs.tredis
    # duf
    # vi-mongo
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
