{
  pkgs,
  lib,
  codex,
  ...
}:
pkgs.writeShellScriptBin "ai-usage" ''
  set -euo pipefail

  # Only needed by the fallback path, which asks the Codex CLI for the limits
  # when the stored token has expired. Sketchybar runs this from launchd, where
  # the user profile is not on PATH.
  export PATH=${lib.makeBinPath [codex]}:"$PATH"

  exec ${pkgs.python3}/bin/python3 ${./ai-usage.py} "$@"
''
