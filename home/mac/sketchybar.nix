{
  config,
  lib,
  pkgs,
  ...
}: let
  sketchybarExe = lib.getExe config.programs.sketchybar.package;

  luaPackage =
    pkgs.lua5_4.withPackages
    (ps:
      with ps; [
        pkgs.sbarlua
      ]);
in {
  programs.sketchybar = {
    enable = lib.mkDefault false;
    inherit luaPackage;
    extraPackages = with pkgs; [
      sketchybar-app-font
    ];
  };

  programs.aerospace.settings.exec-on-workspace-change = lib.mkIf (config.programs.aerospace.enable && config.programs.sketchybar.enable) [
    "/bin/bash"
    "-c"
    "${sketchybarExe} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
  ];

  xdg.configFile = {
    "sketchybar" = {
      enable = config.programs.sketchybar.enable;
      force = true;
      source = ../dotfiles/sketchybar;
      recursive = true;
    };
    "sketchybar/sketchybarrc" = {
      enable = config.programs.sketchybar.enable;
      executable = true;
      force = true;
      text = ''
        #!/usr/bin/env ${lib.getExe config.programs.sketchybar.luaPackage}
        package.cpath = package.cpath .. ";${pkgs.lua54Packages.getLuaCPath pkgs.sbarlua}"
        require("init")
      '';
    };
  };
}
