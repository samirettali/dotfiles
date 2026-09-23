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
    ns = "${lib.getExe' pkgs.nix "nix-shell"} --run $SHELL -p";
    cc = "${lib.getExe' config.programs.claude-code.package "claude"} --continue";
    cr = "${lib.getExe' config.programs.claude-code.package "claude"} --resume";
  };

  # macOS's own trash, which Finder shows and empties: trash-cli used the Linux
  # location, which nothing ever emptied. rm's flags mean nothing to it.
  programs.fish.functions.rm = "/usr/bin/trash (string match -rv -- '^-' $argv)";

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
