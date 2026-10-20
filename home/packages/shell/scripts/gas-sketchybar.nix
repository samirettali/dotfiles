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

    # A launchd agent inherits almost no environment: `sketchybar` publishes the
    # fee from the store.
    export PATH=${lib.makeBinPath [sketchybar]}:"$PATH"

    # `rbw get` on a locked vault would open a pinentry prompt from a background
    # process, so wait for the unlock instead.
    if [ -z "''${INFURA_API_KEY-}" ]; then
      until ${lib.getExe rbw} unlocked 2>/dev/null; do
        echo "rbw vault is locked" >&2
        sleep 60
      done
      if ! INFURA_API_KEY="$(${lib.getExe rbw} get infura-api-key-3)" || [ -z "$INFURA_API_KEY" ]; then
        echo "rbw get infura-api-key-3 failed" >&2
        sleep 60
        exit 1
      fi
      export INFURA_API_KEY
    fi

    exec ${python}/bin/python3 ${./gas-sketchybar.py} "$@"
  ''
