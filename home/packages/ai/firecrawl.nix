{
  config,
  lib,
  nurPkgs,
  pkgs,
  ...
}: let
  rbw =
    if config.programs.rbw.enable
    then config.programs.rbw.package
    else null;
in {
  home.packages = [
    (pkgs.writeShellScriptBin "firecrawl" ''
      set -euo pipefail
      export FIRECRAWL_NO_SEARCH_FEEDBACK=1
      export FIRECRAWL_NO_TELEMETRY=1

      case "''${1-}" in
        feedback|search-feedback) exit 0 ;;
      esac
      for arg in "$@"; do
        case "$arg" in
          --help|-h|--version|-V) exec ${lib.getExe nurPkgs.firecrawl-cli} "$@" ;;
        esac
      done

      ${lib.optionalString (rbw != null) ''
        if [ -z "''${FIRECRAWL_API_KEY-}" ] && ${lib.getExe rbw} unlocked 2>/dev/null; then
          FIRECRAWL_API_KEY="$(${lib.getExe rbw} get firecrawl-api-key)"
          export FIRECRAWL_API_KEY
        fi
      ''}
      if [ -z "''${FIRECRAWL_API_KEY-}" ]; then
        printf '%s\n' 'Firecrawl needs FIRECRAWL_API_KEY or an unlocked rbw entry firecrawl-api-key.' >&2
        exit 1
      fi
      exec ${lib.getExe nurPkgs.firecrawl-cli} "$@"
    '')
  ];
}
