{
  lib,
  pkgs,
  vars,
  neovimPackage,
  ...
}: {
  imports = [
    ./dotfiles.nix
    ./mcp.nix
    ./packages/shell
    ./sops.nix
  ];

  programs.fish.enable = true;

  home.shell = {
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };

  home.shellAliases = {
    ls = "${lib.getExe' pkgs.coreutils "ls"} --color=always --group-directories-first";
    iip = "dig +short myip.opendns.com @resolver1.opendns.com";
    jj = "${vars.commands.paste} | ${lib.getExe pkgs.jq} -r | ${vars.commands.copy}";
    jjj = "${vars.commands.paste} | ${lib.getExe pkgs.jq} -r";
    localip = "ipconfig getifaddr en0";
    rm = lib.getExe pkgs.trash-cli;
    ns = "${lib.getExe' pkgs.nix "nix-shell"} --run $SHELL -p";
    nd = "${lib.getExe pkgs.nix} develop -c $SHELL";
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "firefox";
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
