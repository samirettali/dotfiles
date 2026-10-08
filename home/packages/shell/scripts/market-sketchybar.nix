{
  pkgs,
  lib,
  sketchybar,
  ...
}: let
  python = pkgs.python3.withPackages (ps: [ps.websockets]);
in
  pkgs.writeShellScriptBin "market-sketchybar" ''
    set -euo pipefail

    # A launchd agent inherits almost no environment: `sketchybar` publishes the
    # prices, from the store.
    export PATH=${lib.makeBinPath [sketchybar]}:"$PATH"

    exec ${python}/bin/python3 ${./market-sketchybar.py} "$@"
  ''
