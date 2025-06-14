{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  readTemplate = file:
    builtins.replaceStrings
    ["{{HOME}}"]
    ["${config.home.homeDirectory}"]
    (builtins.readFile file);
in {
  home.packages =
    [
      (pkgs.writeShellScriptBin "glc" (builtins.readFile dotfiles/scripts/glc.sh))
      (pkgs.writeShellScriptBin "tad" (builtins.readFile dotfiles/scripts/tad.sh))
      (pkgs.writeShellScriptBin "ticker" (builtins.readFile dotfiles/scripts/ticker.sh))
      (pkgs.writeShellScriptBin "extract" (builtins.readFile dotfiles/scripts/extract.sh))
      (pkgs.writeShellScriptBin "zv" ''
        #!/usr/bin/env bash

        set -euo pipefail

        if [ -z "$1" ]; then
            echo "Usage: zvim <target>"
            exit 1
        fi

        target=$(${lib.getExe pkgs.zoxide} query -l)

        cd "''${target}" || exit 1

        ${lib.getExe inputs.neovim-nightly-overlay.packages.${pkgs.system}.default} .
      '')
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      (pkgs.writeShellScriptBin "passbemenu" (builtins.readFile dotfiles/scripts/passbemenu.sh))
      (pkgs.writeShellScriptBin "scratchpad" (builtins.readFile dotfiles/scripts/scratchpad.sh))
      (pkgs.writeShellScriptBin "screenshot" (builtins.readFile dotfiles/scripts/screenshot.sh))
    ];

  home.file = lib.mkMerge [
    {
      ".ideavimrc".source = dotfiles/ideavimrc;
      ".Xdefaults".source = dotfiles/Xdefaults;
      "revive.toml".source = dotfiles/revive.toml;
      ".config/ghostty/config".source = dotfiles/ghostty;

      ".config/nvim" = {
        source = dotfiles/nvim;
        recursive = true;
      };
      ".config/git-sync/config.yaml".text = readTemplate dotfiles/git-sync.yaml;
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      ".bin/passbemenu".source = dotfiles/scripts/passbemenu.sh;
      ".bin/scratchpad".source = dotfiles/scripts/scratchpad.sh;
      ".bin/screenshot".source = dotfiles/scripts/screenshot.sh;
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      ".hammerspoon" = {
        source = dotfiles/hammerspoon;
        recursive = true;
      };
      ".config/raycast/scripts" = {
        source = dotfiles/scripts/raycast;
        recursive = true;
      };
      ".config/sketchybar" = {
        source = dotfiles/sketchybar;
        recursive = true;
      };
    })
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.bin"
  ];
}
