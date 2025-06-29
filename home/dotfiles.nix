{
  lib,
  pkgs,
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
            echo "Usage: zv <target>"
            exit 1
        fi

        target=$(${lib.getExe pkgs.zoxide} query "''${1}")

        cd "''${target}" || exit 1

        ${lib.getExe pkgs.neovim} .
      '')
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      (pkgs.writeShellScriptBin "passbemenu" (builtins.readFile dotfiles/scripts/passbemenu.sh))
      (pkgs.writeShellScriptBin "screenshot" (builtins.readFile dotfiles/scripts/screenshot.sh))
    ];

  home.file = lib.mkMerge [
    {
      ".ideavimrc".source = dotfiles/ideavimrc;
      ".Xdefaults".source = dotfiles/Xdefaults;
      "revive.toml".source = dotfiles/revive.toml;

      ".config/nvim" = {
        source = dotfiles/nvim;
        recursive = true;
      };
    }
  ];
}
