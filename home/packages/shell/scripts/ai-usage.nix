{
  pkgs,
  lib,
  codex,
  antigravity-cli,
  grok-cli,
  ...
}:
pkgs.writeShellScriptBin "ai-usage" ''
  set -euo pipefail

  # The CLIs are only needed by the fallback paths, which ask them for the
  # limits when the stored token has expired. Sketchybar runs this from
  # launchd, where the user profile is not on PATH.
  export PATH=${lib.makeBinPath [codex antigravity-cli grok-cli]}:"$PATH"

  exec ${pkgs.python3}/bin/python3 ${./ai-usage.py} "$@"
''
