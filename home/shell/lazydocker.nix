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

  programs.fish.shellAliases = lib.mkIf config.programs.lazydocker.enable {
    ld = lib.getExe pkgs.lazydocker;
  };

  programs.zsh.shellAliases = lib.mkIf config.programs.lazydocker.enable {
    ld = "${lib.getExe pkgs.lazydocker}";
  };
}
