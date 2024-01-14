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
    bcc
    cointop
    curl
    diskus
    fd
    git-crypt
    htop
    iredis
    jq
    lazydocker
    lazygit
    lnav
    moreutils
    mprocs
    ncdu
    neovim-nightly
    ngrok
    p7zip
    pgcli
    ripgrep
    tmux
    tmuxinator
    trash-cli
    tree
    ueberzugpp
    unixtools.xxd
    unzip
    watchexec
    yazi
    zellij
  ];

  programs = {
    bat = {
      enable = true;
      config = {
        theme = "ansi";
      };
      extraPackages = with pkgs.bat-extras; [ batgrep ];
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
  };
}
