{
  config,
  pkgs,
  lib,
  ...
}: let
  rbw =
    if config.programs.rbw.enable
    then config.programs.rbw.package
    else null;

  # The scripts read their keys from the environment and nothing else, so the
  # skills call these wrappers instead of `uv run` and the vault stays a detail
  # of this file. Without them the skill fails with "GEMINI_API_KEY is not set"
  # halfway through a job.
  wrap = {
    name,
    script,
    vars,
  }:
    pkgs.writeShellScriptBin name ''
      set -euo pipefail
      ${lib.concatMapStrings (v: ''
          ${lib.optionalString (rbw != null) ''
            if [ -z "''${${v.env}-}" ] && ${lib.getExe rbw} unlocked 2>/dev/null; then
              ${v.env}="$(${lib.getExe rbw} get ${v.entry})"
              export ${v.env}
            fi
          ''}
        '')
        vars}
      exec ${lib.getExe pkgs.uv} run --quiet ${script} "$@"
    '';
in {
  home.packages = [
    (wrap {
      name = "generate-image";
      script = ./skills/generate-image/scripts/generate_image.py;
      vars = [
        {
          env = "GEMINI_API_KEY";
          entry = "gemini-api-key";
        }
        {
          env = "OPENAI_API_KEY";
          entry = "openai-api-key";
        }
      ];
    })
    (wrap {
      name = "generate-music";
      script = ./skills/generate-music/scripts/generate_music.py;
      vars = [
        {
          env = "GEMINI_API_KEY";
          entry = "gemini-api-key";
        }
      ];
    })
    (wrap {
      name = "generate-speech";
      script = ./skills/generate-speech/scripts/generate_speech.py;
      vars = [
        {
          env = "GEMINI_API_KEY";
          entry = "gemini-api-key";
        }
      ];
    })
    (wrap {
      name = "x-search";
      script = ./skills/x-search/scripts/x_search.py;
      vars = [
        {
          env = "XAI_API_KEY";
          entry = "xai-api-key";
        }
      ];
    })
  ];
}
