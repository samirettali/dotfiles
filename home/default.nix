{
  lib,
  pkgs,
  config,
  neovimPackage,
  ...
}: {
  imports = [
    ./ai.nix
    ./dotfiles.nix
    ./options.nix
    ./packages/shell
  ];

  home.shell = {
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };

  home.shellAliases = {
    ls = "${lib.getExe' pkgs.coreutils "ls"} --color=auto --group-directories-first";
    rm = lib.getExe pkgs.trash-cli;
    ns = "${lib.getExe' pkgs.nix "nix-shell"} --run $SHELL -p";
    cc = "${lib.getExe config.programs.claude-code.package}/bin/claude --continue";
    cr = "${lib.getExe config.programs.claude-code.package}/bin/claude resume";
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "helium";
    MANPAGER = "${lib.getExe neovimPackage} -c 'Man!' -";
  };

  programs = {
    home-manager.enable = true;
    nix-init.enable = true;
  };

  home.packages = with pkgs; [
    cachix
    nix-tree
    nix-prefetch-github
  ];

  home.file.".hushlogin".text = "";
}
