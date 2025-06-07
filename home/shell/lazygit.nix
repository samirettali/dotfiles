{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showBottomLine = false;
        autoForwardBranches = "none";
      };
      git = {
        overrideGpg = true;
      };
    };
  };

  programs.fish.shellAliases = lib.mkIf config.programs.lazygit.enable {
    lg = lib.getExe pkgs.lazygit;
  };

  programs.zsh.shellAliases = lib.mkIf config.programs.lazygit.enable {
    lg = "${lib.getExe pkgs.lazygit}";
  };
}
