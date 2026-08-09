{
  pkgs,
  lib,
  spotctl,
  tokenFile ? null,
  ...
}:
pkgs.writeShellScriptBin "lyrics" ''
  set -euo pipefail

  export PATH=${lib.makeBinPath [spotctl]}:"$PATH"
  ${lib.optionalString (tokenFile != null) ''
    if [ -z "''${GENIUS_ACCESS_TOKEN:-}" ] && [ -r ${lib.escapeShellArg tokenFile} ]; then
      GENIUS_ACCESS_TOKEN="$(cat ${lib.escapeShellArg tokenFile})"
      export GENIUS_ACCESS_TOKEN
    fi
  ''}

  exec ${pkgs.python3}/bin/python3 ${./lyrics.py} "$@"
''
