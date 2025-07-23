{
  lib,
  pkgs,
  customArgs,
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

  programs.fish.enable = true;

  home.shell = {
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };

  home.shellAliases = {
    ls = "${lib.getExe' pkgs.uutils-coreutils-noprefix "ls"} --color=always --group-directories-first";
    iip = "dig +short myip.opendns.com @resolver1.opendns.com";
    jj = "${customArgs.commands.paste} | ${lib.getExe pkgs.jq} -r | ${customArgs.commands.copy}";
    jjj = "${customArgs.commands.paste} | ${lib.getExe pkgs.jq} -r";
    localip = "ipconfig getifaddr en0";
    rm = lib.getExe pkgs.trash-cli;
    ns = "${lib.getExe' pkgs.nix "nix-shell"} --run $SHELL -p";
    nd = "${lib.getExe pkgs.nix} develop -c $SHELL";
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
    cachix
    code-cursor
    nix-init
    nix-prefetch-github
  ];

  home.file.".hushlogin".text = "";
}
