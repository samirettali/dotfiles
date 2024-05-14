{ lib
, pkgs
, ...
}: {
  imports = [
    ./zsh.nix
    ./tmux.nix
    ./pass.nix
    ./fzf.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    curl
    diskus
    fd
    htop
    iredis
    jq
    lazydocker
    lazygit
    moreutils
    mprocs
    ncdu
    neovim-nightly
    ngrok
    p7zip
    pgcli
    ripgrep
    tmux
    trash-cli
    tree
    unzip
    watchexec
    graphviz
  ];

  programs = {
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
  };
}
