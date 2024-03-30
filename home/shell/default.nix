{ lib
, pkgs
, inputs
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
    ngrok
    p7zip
    graphviz
    pgcli
    ripgrep
    tmux
    trash-cli
    tree
    unzip
    visidata
    watchexec
    graphviz
    youtube-dl
  ];

  programs = {
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
    zellij = {
      enable = lib.mkDefault true;
      enableZshIntegration = false;
      settings = {
        # theme = "custom";
        # themes.custom.fg = "#ffffff";

      };
    };
  };
}
