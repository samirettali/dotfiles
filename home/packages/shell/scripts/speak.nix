{
  pkgs,
  lib,
  rbw ? null,
  ...
}: let
  python = pkgs.python3.withPackages (ps: [ps.websockets]);
in
  pkgs.writeShellScriptBin "speak" ''
    set -euo pipefail

    export PATH=${lib.makeBinPath [pkgs.mpv]}:"$PATH"
    ${lib.optionalString (rbw != null) ''
      # speak.py only ever reads the environment, so where the key is kept stays
      # a decision of this wrapper. Filled in only when the caller has not
      # exported one already.
      if [ -z "''${ELEVENLABS_API_KEY-}" ]; then
        if ${lib.getExe rbw} unlocked 2>/dev/null; then
          ELEVENLABS_API_KEY="$(${lib.getExe rbw} get elevenlabs)"
          export ELEVENLABS_API_KEY
        else
          # Locked mid-turn: a pinentry nobody is watching would block the agent
          # until it times out. Swallow the text and stay quiet instead.
          exec ${lib.getExe' pkgs.coreutils "cat"} >/dev/null
        fi
      fi
    ''}
    exec ${python}/bin/python3 ${./speak.py} "$@"
  ''
