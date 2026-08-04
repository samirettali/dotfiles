{
  config,
  lib,
  pkgs,
  ...
}: let
  sketchybarExe = lib.getExe config.programs.sketchybar.package;

  luaposixPackage = pkgs.callPackage ./luaposix.nix {
    inherit (pkgs.lua55Packages) buildLuarocksPackage;
  };

  luasimdjsonPackage = pkgs.callPackage ./simdjson.nix {
    inherit (pkgs.lua55Packages) buildLuarocksPackage;
  };

  luaPackage =
    pkgs.lua5_5.withPackages
    (ps:
      with ps; [
        cjson
        pkgs.sbarlua
        luaposixPackage
        luasimdjsonPackage
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
        package.cpath = package.cpath .. ";${pkgs.lua55Packages.getLuaCPath pkgs.sbarlua}"
        package.cpath = package.cpath .. ";${pkgs.lua55Packages.getLuaCPath luaposixPackage}"
        package.cpath = package.cpath .. ";${pkgs.lua55Packages.getLuaCPath luasimdjsonPackage}"
        AEROSPACE_BIN = "${lib.getExe config.programs.aerospace.package}"
        require("init")
      '';
    };
  };
}
