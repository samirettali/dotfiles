{
  pkgs,
  lib,
  herdr,
  sketchybar,
  ...
}:
pkgs.writeShellScriptBin "herdr-sketchybar" ''
  set -euo pipefail

  # A launchd agent inherits almost no environment, and this needs both
  # `sketchybar` (to publish) and `herdr` (to count). Both come from the store:
  # with `useUserPackages` the user profile lives at
  # /etc/profiles/per-user/$USER/bin rather than ~/.nix-profile/bin, and guessing
  # that path once already left the watcher silently counting zero.
  export PATH=${lib.makeBinPath [sketchybar herdr]}:"$PATH"

  exec ${pkgs.python3}/bin/python3 ${./herdr-sketchybar.py} "$@"
''
