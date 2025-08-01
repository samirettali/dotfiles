{
  config,
  lib,
  pkgs,
  ...
}: let
  jqExe = lib.getExe pkgs.jq;
  trExe = lib.getExe' pkgs.uutils-coreutils-noprefix "tr";
  websocatExe = lib.getExe pkgs.websocat;
  sketchybarExe = lib.getExe config.programs.sketchybar.package;

  cryptoMonitorScript = pkgs.writeShellScriptBin "crypto-monitor" ''
    if [[ $# -eq 0 ]]; then
        echo "Usage: ./''${0} <BTCUSDT> [ETHUSDT ...]"
        exit 1
    fi

    PAIRS=("''${@:1}")

    declare -A tickers
    declare -A icons

    icons["BTC"]="₿"
    icons["ETH"]=""
    icons["SOL"]="◎"
    icons["AAVE"]="Ӕ"

    update_sketchybar() {
        local parts=()

        for symbol in "''${PAIRS[@]}"; do
            local price
            price="''${tickers[$symbol]}"

            if [[ -z "$price" ]]; then
                continue
            fi

            local formatted_price

            formatted_price=$(printf "%.2f" "$price")

            local base_asset="''${symbol%USDT}"

            local icon="''${icons[$base_asset]:-$base_asset}"

            parts+=("$icon $formatted_price")
        done

        local result
        result=$(
            IFS=' '
            echo "''${parts[*]}"
        )

        echo "$result"

        ${sketchybarExe} --trigger crypto_price_change "VALUE=$result" 2>/dev/null || true
    }

    process_ticker() {
        local json_msg="$1"

        local symbol
        symbol=$(echo "$json_msg" | ${jqExe} -r '.s // empty' 2>/dev/null)

        local price
        price=$(echo "$json_msg" | ${jqExe} -r '.c // empty' 2>/dev/null)

        local quote_volume
        quote_volume=$(echo "$json_msg" | ${jqExe} -r '.q // empty' 2>/dev/null)

        if [[ -n "$symbol" && -n "$price" && -n "$quote_volume" && "$price" != "null" && "$quote_volume" != "null" ]]; then
            tickers["$symbol"]="$price"
            update_sketchybar
        fi
    }

    create_subscription() {
        local params=""
        for pair in "''${PAIRS[@]}"; do
            local lower_pair
            lower_pair=$(echo "$pair" | ${trExe} '[:upper:]' '[:lower:]')
            if [[ -n "$params" ]]; then
                params+=","
            fi
            params+="\"''${lower_pair}@miniTicker\""
        done

        echo "{\"method\":\"SUBSCRIBE\",\"params\":[$params]}"
    }

    subscription=$(create_subscription)

    {
        echo "$subscription"
        while true; do sleep 1; done
    } | ${websocatExe} wss://stream.binance.com/ws | while IFS= read -r line; do
        # skip first response
        if echo "$line" | ${jqExe} -e '.result // false' &>/dev/null; then
            continue
        fi

        if echo "$line" | ${jqExe} -e '.e == "24hrMiniTicker"' &>/dev/null; then
            process_ticker "$line"
        fi
    done
  '';
in {
  programs.sketchybar = {
    enable = true;
  };

  programs.aerospace.userSettings.exec-on-workspace-change = lib.mkIf config.programs.aerospace.enable [
    "/bin/bash"
    "-c"
    "${sketchybarExe} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
  ];

  home.file = {
    ".config/sketchybar" = {
      source = ../dotfiles/sketchybar;
      recursive = true;
    };
  };

  launchd.agents.crypto-monitor = {
    enable = true;
    config = {
      ProgramArguments = [
        (lib.getExe cryptoMonitorScript)
        "BTCUSDT"
        "ETHUSDT"
        "AAVEUSDT"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/crypto-monitor.log";
      StandardErrorPath = "/tmp/crypto-monitor.error.log";
    };
  };
}
