{
  pkgs,
  lib,
  rbw,
  sketchybar,
  ...
}:
pkgs.writeShellScriptBin "mail-sketchybar" ''
  set -euo pipefail

  # A launchd agent inherits almost no environment: `sketchybar` publishes the
  # count from the store.
  export PATH=${lib.makeBinPath [sketchybar]}:"$PATH"

  # `rbw get` on a locked vault would open a pinentry prompt from a background
  # process, so wait for the unlock instead.
  if [ -z "''${FASTMAIL_API_KEY-}" ]; then
    until ${lib.getExe rbw} unlocked 2>/dev/null; do
      echo "rbw vault is locked" >&2
      sleep 60
    done
    if ! FASTMAIL_API_KEY="$(${lib.getExe rbw} get fastmail-api-key)" || [ -z "$FASTMAIL_API_KEY" ]; then
      echo "rbw get fastmail-api-key failed" >&2
      sleep 60
      exit 1
    fi
    export FASTMAIL_API_KEY
  fi

  exec ${pkgs.python3}/bin/python3 ${./mail-sketchybar.py} "$@"
''
