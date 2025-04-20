{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
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

        target=$(${pkgs.zoxide}/bin/zoxide query -l)

        cd "''${target}" || exit 1

        ${inputs.neovim-nightly-overlay.packages.${pkgs.system}.default}/bin/nvim .
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
      ".config/git-sync/config.yaml".text = let
        templ = builtins.readFile dotfiles/git-sync.yaml;
      in
        builtins.replaceStrings
        ["{{HOME}}"]
        ["${config.home.homeDirectory}"]
        templ;
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      ".bin/passbemenu".source = dotfiles/scripts/passbemenu.sh;
      ".bin/scratchpad".source = dotfiles/scripts/scratchpad.sh;
      ".bin/screenshot".source = dotfiles/scripts/screenshot.sh;
      ".config/lazydocker/config.yml".source = dotfiles/lazydocker.yml;
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
      "Library/Application Support/jesseduffield/lazydocker/config.yml".source = dotfiles/lazydocker.yml;
    })
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.bin"
  ];
}
