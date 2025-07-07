{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./dotfiles.nix
    ./git-sync.nix
    ./services/default.nix
    ./shell
    ./sops.nix
    ./spotify-player.nix
  ];

  home.shell = {
    enableZshIntegration = config.programs.zsh.enable;
    enableFishIntegration = config.programs.fish.enable;
  };

  programs = {
    zsh.shellAliases = {
      ls = "${lib.getExe' pkgs.uutils-coreutils-noprefix "ls"} --color=always --group-directories-first";
    };
    fish.shellAliases = {
      ls = "${lib.getExe' pkgs.uutils-coreutils-noprefix "ls"} --color=always --group-directories-first";
    };
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "firefox";
    TERMINAL = "ghostty";
    MANPAGER = "${lib.getExe pkgs.neovim} -c 'Man!' -";
  };

  programs = {
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    code-cursor
    nix-init
    nix-prefetch-github
    nix-update
  ];

  home.file.".hushlogin".text = "";
}
