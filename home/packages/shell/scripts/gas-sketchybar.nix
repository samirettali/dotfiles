{
  pkgs,
  lib,
  rbw,
  sketchybar,
  ...
}: let
  python = pkgs.python3.withPackages (ps: [ps.websockets]);
in
  pkgs.writeShellScriptBin "gas-sketchybar" ''
    set -euo pipefail

    # A launchd agent inherits almost no environment: `rbw` reads the Infura key
    # and `sketchybar` publishes the fee, both from the store.
    export PATH=${lib.makeBinPath [rbw sketchybar]}:"$PATH"

    exec ${python}/bin/python3 ${./gas-sketchybar.py} "$@"
  ''
