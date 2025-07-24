{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.lazygit = {
    enable = config.programs.git.enable;
    settings = {
      gui = {
        showBottomLine = false;
        autoForwardBranches = "none";
      };
      git = {
        overrideGpg = true;
      };
      promptToReturnFromSubprocess = false;
    };
  };

  home.shellAliases = lib.mkIf config.programs.lazygit.enable {
    lg = lib.getExe pkgs.lazygit;
  };
}
