{
  pkgs,
  lib,
  spotctl,
  rbw ? null,
  ...
}:
pkgs.writeShellScriptBin "lyrics" ''
  set -euo pipefail

  export PATH=${lib.makeBinPath [spotctl]}:"$PATH"
  ${lib.optionalString (rbw != null) ''
    # lyrics.py only reads the environment; where the token is kept is decided
    # here. A locked vault is not an error: the script skips Genius without one.
    if [ -z "''${GENIUS_ACCESS_TOKEN:-}" ] && ${lib.getExe rbw} unlocked 2>/dev/null; then
      GENIUS_ACCESS_TOKEN="$(${lib.getExe rbw} get genius)"
      export GENIUS_ACCESS_TOKEN
    fi
  ''}

  exec ${pkgs.python3}/bin/python3 ${./lyrics.py} "$@"
''
