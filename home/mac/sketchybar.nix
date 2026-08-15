{
  config,
  lib,
  pkgs,
  inputs,
  nurPkgs,
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

  herdrPackage = import ../packages/shell/herdr-package.nix {inherit inputs nurPkgs;};

  herdrSketchybar = pkgs.callPackage ../packages/shell/scripts/herdr-sketchybar.nix {
    sketchybar = config.programs.sketchybar.package;
    herdr = herdrPackage;
  };

  aiUsage = pkgs.callPackage ../packages/shell/scripts/ai-usage.nix {
    codex = nurPkgs.codex;
  };
in {
  programs.sketchybar = {
    enable = true;
    inherit luaPackage;
    extraPackages = with pkgs; [
      sketchybar-app-font
    ];
  };

  # Holds Herdr's socket open and triggers the `herdr_agents` event, so the item
  # is pushed rather than polled. Runs as a LaunchAgent because SbarLua cannot
  # keep a socket of its own; it survives Herdr restarts by reconnecting.
  launchd.agents.herdr-sketchybar = {
    enable = config.programs.sketchybar.enable;
    config = {
      ProgramArguments = [(lib.getExe herdrSketchybar)];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/herdr-sketchybar.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/herdr-sketchybar.err.log";
    };
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
        SKETCHYBAR_BIN = "${sketchybarExe}"
        HERDR_BIN = "${lib.getExe herdrPackage}"
        AI_USAGE_BIN = "${lib.getExe aiUsage}"
        require("init")
      '';
    };
  };
}
