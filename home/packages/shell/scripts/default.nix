{
  pkgs,
  lib,
  neovimPackage,
  ...
}: let
  copy = pkgs.callPackage ./copy.nix {};
  scriptsDir = ../../../dotfiles/scripts;
in {
  home.packages =
    [
      copy
      (pkgs.callPackage ./nhash.nix {
        inherit copy;
      })
      (pkgs.writeShellScriptBin "glc" (builtins.readFile "${scriptsDir}/glc.sh"))
      (pkgs.writeShellScriptBin "tad" (builtins.readFile "${scriptsDir}/tad.sh"))
      (pkgs.writeShellScriptBin "ticker" (builtins.readFile "${scriptsDir}/ticker.sh"))
      (pkgs.writeShellScriptBin "extract" (builtins.readFile "${scriptsDir}/extract.sh"))
      (pkgs.writeShellScriptBin "zv" ''
        set -euo pipefail

        if [ -z "$1" ]; then
            echo "Usage: zv <target>"
            exit 1
        fi

        target=$(${lib.getExe pkgs.zoxide} query "''${1}")

        cd "''${target}" || exit 1

        ${lib.getExe neovimPackage} .
      '')
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      (pkgs.writeShellScriptBin "passbemenu" (builtins.readFile "${scriptsDir}/passbemenu.sh"))
      (pkgs.writeShellScriptBin "screenshot" (builtins.readFile "${scriptsDir}/screenshot.sh"))
    ];
}
