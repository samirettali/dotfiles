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

  programs.fish.shellAliases = {
    s = "${lib.getExe zesh} cn $(basename $(${lib.getExe zesh} l | ${lib.getExe config.programs.television.package}))";
    zl = "${lib.getExe config.programs.zellij.package} ls";
    za = "${lib.getExe config.programs.zellij.package} attach -c";
  };
}
