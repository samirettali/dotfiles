{
  pkgs,
  lib,
  ...
}: let
  python = pkgs.python3.withPackages (ps: [ps.websockets]);
in
  pkgs.writeShellScriptBin "speak" ''
    set -euo pipefail

    export PATH=${lib.makeBinPath [pkgs.mpv]}:"$PATH"

    exec ${python}/bin/python3 ${./speak.py} "$@"
  ''
