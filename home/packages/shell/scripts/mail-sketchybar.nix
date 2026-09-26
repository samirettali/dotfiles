{
  pkgs,
  lib,
  rbw,
  sketchybar,
  ...
}:
pkgs.writeShellScriptBin "mail-sketchybar" ''
  set -euo pipefail

  # A launchd agent inherits almost no environment: `rbw` reads the token and
  # `sketchybar` publishes the count, both from the store.
  export PATH=${lib.makeBinPath [rbw sketchybar]}:"$PATH"

  exec ${pkgs.python3}/bin/python3 ${./mail-sketchybar.py} "$@"
''
