{
  pkgs,
  lib,
  ...
}: let
  cat = lib.getExe' pkgs.uutils-coreutils-noprefix "cat";
  base64 = lib.getExe' pkgs.uutils-coreutils-noprefix "base64";
in
  pkgs.writeShellScriptBin "copy" ''
    set -euo pipefail

    b64_data=$(${cat} | ${base64} -w0)

    printf "\e]52;c;%s\a" "''${b64_data}"
  ''
