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

  home.shellAliases = lib.mkIf config.programs.lazygit.enable {
    lg = lib.getExe pkgs.lazygit;
  };
}
