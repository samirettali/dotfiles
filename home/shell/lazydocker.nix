{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.lazydocker = {
    enable = lib.mkDefault false;
    settings = {
      gui = {
        showBottomLine = false;
        returnImmediately = true;
      };
    };
  };

  home.shellAliases = lib.mkIf config.programs.lazydocker.enable {
    ld = lib.getExe pkgs.lazydocker;
  };
}
