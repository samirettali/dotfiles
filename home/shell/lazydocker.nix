{
  lib,
  pkgs,
  config,
  ...
}: {
  programs = {
    lazydocker = {
      enable = true;
      settings = {
        gui = {
          showBottomLine = false;
          returnImmediately = true;
        };
      };
    };
  };

  home.shellAliases = lib.mkIf config.programs.lazydocker.enable {
    ld = lib.getExe pkgs.lazydocker;
  };
}
