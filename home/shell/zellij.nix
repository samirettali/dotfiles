{
  pkgs,
  lib,
  config,
  samirettali-nur,
  ...
}: let
  zesh =
    samirettali-nur.packages.${pkgs.system}.zesh;
in {
  home.packages = [
    zesh
    pkgs.zjstatus
  ];

  programs = {
    zellij = {
      enable = true;
    };
  };

  programs.fish.interactiveShellInit =
    lib.mkIf (config.programs.zellij.enable && config.programs.ghostty.enable)
    (lib.mkBefore
      /*
      fish
      */
      ''
        if [ "$TERM" = "xterm-ghostty" ]
            eval (${lib.getExe pkgs.zellij} setup --generate-auto-start fish | string collect)
        end
      '');
}
