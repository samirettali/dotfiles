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
  inherit (config.programs.git.settings) user;
in {
  # The keys come from the rbw vault when it is unlocked. EDGAR is keyless and
  # only needs a name and an email, so financials and filings work either way.
  home.packages = [
    (pkgs.writeShellScriptBin "finctl" ''
      set -euo pipefail
      export EDGAR_USER_AGENT="''${EDGAR_USER_AGENT:-${user.name} ${user.email}}"
      ${lib.optionalString (rbw != null) ''
        if ${lib.getExe rbw} unlocked 2>/dev/null; then
          if [ -z "''${FINCTL_IBKR_TOKEN-}" ]; then
            FINCTL_IBKR_TOKEN="$(${lib.getExe rbw} get ibkr-flex-token)"
            export FINCTL_IBKR_TOKEN
          fi
          if [ -z "''${FINCTL_IBKR_QUERY_ID-}" ]; then
            FINCTL_IBKR_QUERY_ID="$(${lib.getExe rbw} get ibkr-flex-query-id)"
            export FINCTL_IBKR_QUERY_ID
          fi
          if [ -z "''${FINNHUB_API_KEY-}" ]; then
            FINNHUB_API_KEY="$(${lib.getExe rbw} get finnhub-api-key)"
            export FINNHUB_API_KEY
          fi
        fi
      ''}
      exec ${lib.getExe nurPkgs.finctl} "$@"
    '')
  ];
}
