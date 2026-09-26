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
  cli = lib.getExe nurPkgs.firecrawl-cli;
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
          --help|-h|--version|-V) exec ${cli} "$@" ;;
        esac
      done

      # An exported FIRECRAWL_API_KEY alone, otherwise one key per account from
      # the vault, in order: the second account takes over when the first runs
      # out of credits.
      keys=()
      if [ -n "''${FIRECRAWL_API_KEY-}" ]; then
        keys=("$FIRECRAWL_API_KEY")
      ${lib.optionalString (rbw != null) ''
        elif ${lib.getExe rbw} unlocked 2>/dev/null; then
          for entry in firecrawl-api-key firecrawl-api-key-2; do
            if key="$(${lib.getExe rbw} get "$entry" 2>/dev/null)"; then
              keys+=("$key")
            fi
          done
      ''}
      fi
      if [ "''${#keys[@]}" -eq 0 ]; then
        printf '%s\n' 'Firecrawl needs FIRECRAWL_API_KEY or an unlocked rbw entry firecrawl-api-key.' >&2
        exit 1
      fi

      # The CLI does not retry a 429. Each account has its own per-minute limit,
      # so a 429 moves on to the next account; only when all of them are limited
      # does it wait, for as long as the error says, up to three minutes in all.
      err="$(mktemp)"
      trap 'rm -f "$err"' EXIT
      waited=0
      while :; do
        limited=0
        for i in "''${!keys[@]}"; do
          [ -n "''${keys[$i]}" ] || continue
          status=0
          FIRECRAWL_API_KEY="''${keys[$i]}" ${cli} "$@" 2>"$err" || status=$?
          if [ "$status" -eq 0 ]; then
            cat "$err" >&2
            exit 0
          elif grep -q '"status":429' "$err"; then
            limited=1
          elif grep -qE '"status":402|Insufficient credits' "$err"; then
            keys[i]=""
          else
            cat "$err" >&2
            exit "$status"
          fi
        done
        if [ "$limited" -eq 0 ]; then
          printf '%s\n' 'firecrawl: every account is out of credits.' >&2
          exit 1
        fi
        delay="$(sed -nE 's/.*retry after ([0-9]+)s.*/\1/p' "$err" | head -n 1)"
        delay="''${delay:-30}"
        if [ $((waited + delay)) -gt 180 ]; then
          cat "$err" >&2
          exit 1
        fi
        printf 'firecrawl: rate limited, retrying in %ss\n' "$delay" >&2
        sleep "$delay"
        waited=$((waited + delay))
      done
    '')
  ];
}
