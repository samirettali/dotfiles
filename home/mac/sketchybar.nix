{
  config,
  lib,
  pkgs,
  inputs,
  nurPkgs,
  vars,
  ...
}: let
  sketchybarExe = lib.getExe config.programs.sketchybar.package;

  luaposixPackage = pkgs.callPackage ./luaposix.nix {
    inherit (pkgs.lua55Packages) buildLuarocksPackage;
  };

  luaPackage =
    pkgs.lua5_5.withPackages
    (ps:
      with ps; [
        cjson
        pkgs.sbarlua
        luaposixPackage
      ]);

  herdrPackage = import ../packages/shell/herdr-package.nix {inherit inputs pkgs;};

  herdrSketchybar = pkgs.callPackage ../packages/shell/scripts/herdr-sketchybar.nix {
    sketchybar = config.programs.sketchybar.package;
    herdr = herdrPackage;
  };

  mailSketchybar = pkgs.callPackage ../packages/shell/scripts/mail-sketchybar.nix {
    sketchybar = config.programs.sketchybar.package;
    rbw = config.programs.rbw.package;
  };

  aiUsage = pkgs.callPackage ../packages/shell/scripts/ai-usage.nix {
    inherit (nurPkgs) codex;
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

  # Holds Fastmail's JMAP event stream open and triggers the `mail_unread` event.
  launchd.agents.mail-sketchybar = {
    enable = config.programs.sketchybar.enable && config.programs.rbw.enable;
    config = {
      ProgramArguments = [(lib.getExe mailSketchybar)];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/mail-sketchybar.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/mail-sketchybar.err.log";
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
      onChange = ''
        /bin/launchctl kickstart -k "gui/$UID/org.nix-community.home.sketchybar" 2>/dev/null || true
      '';
    };
    "sketchybar/sketchybarrc" = {
      enable = config.programs.sketchybar.enable;
      executable = true;
      force = true;
      text = ''
        #!/usr/bin/env ${lib.getExe config.programs.sketchybar.luaPackage}
        SKETCHYBAR_BIN = "${sketchybarExe}"
        HERDR_BIN = "${lib.getExe herdrPackage}"
        -- vars.font in flake.nix, shared with Ghostty, Zed and sottomano.
        FONT = "${vars.font.name}"
        AI_USAGE_BIN = "${lib.getExe aiUsage}"
        require("init")
      '';
    };
  };
}
