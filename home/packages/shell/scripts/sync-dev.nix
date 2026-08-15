{
  git,
  lib,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "sync-dev" ''
  set -euo pipefail

  export PATH=${lib.makeBinPath [git]}:"$PATH"

  exec ${pkgs.python3}/bin/python3 ${./sync-dev.py} "$@"
''
