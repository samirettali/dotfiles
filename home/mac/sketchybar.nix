{
  config,
  lib,
  pkgs,
  inputs,
  vars,
  ...
}: let
  sketchybarExe = lib.getExe config.programs.sketchybar.package;

  luaposixPackage = pkgs.callPackage ./luaposix.nix {
    inherit (pkgs.lua55Packages) buildLuarocksPackage;
  };

  luaPackage =
    pkgs.lua5_5.withPackages
    (ps:
      with ps; [
        cjson
        pkgs.sbarlua
        luaposixPackage
      ]);

  herdrPackage = import ../packages/shell/herdr-package.nix {inherit inputs pkgs;};

  herdrSketchybar = pkgs.callPackage ../packages/shell/scripts/herdr-sketchybar.nix {
    sketchybar = config.programs.sketchybar.package;
    herdr = herdrPackage;
  };

  mailSketchybar = pkgs.callPackage ../packages/shell/scripts/mail-sketchybar.nix {
    sketchybar = config.programs.sketchybar.package;
    rbw = config.programs.rbw.package;
  };

  gasSketchybar = pkgs.callPackage ../packages/shell/scripts/gas-sketchybar.nix {
    sketchybar = config.programs.sketchybar.package;
    rbw = config.programs.rbw.package;
  };

  marketSketchybar = pkgs.callPackage ../packages/shell/scripts/market-sketchybar.nix {
    sketchybar = config.programs.sketchybar.package;
  };

  # The market popup's status dots, one PNG per status.
  marketDots = pkgs.runCommand "sketchybar-market-dots" {} ''
    ${lib.getExe pkgs.python3} ${./sketchybar-dots.py} $out
  '';

  # Every price followed, in the order the popup lists them. Crypto comes from
  # Binance against USDT; stocks and the macro group (indices, currencies,
  # commodities) from Yahoo Finance under Yahoo's symbol. TradingView, under its
  # own symbol, says which session each Yahoo market is in. Only crypto and
  # stocks have a market cap, and so a figure in the bar.
  markets = let
    crypto = name: {
      symbol = "${name}USDT";
      source = "binance";
      group = "crypto";
      inherit name;
    };
    stock = exchange: symbol: {
      inherit symbol;
      source = "yahoo";
      group = "stocks";
      name = symbol;
      tradingview = "${exchange}:${symbol}";
    };
    macro = symbol: name: tradingview: {
      inherit symbol name tradingview;
      source = "yahoo";
      group = "macro";
    };
  in
    builtins.toFile "markets.json" (builtins.toJSON [
      (crypto "BTC")
      (crypto "ETH")
      (crypto "AAVE")
      (crypto "SOL")
      (stock "NASDAQ" "GOOG")
      (stock "NASDAQ" "NVDA")
      (stock "NYSE" "NET")
      (stock "NYSE" "SNOW")
      (stock "NASDAQ" "SPCX")
      (stock "NASDAQ" "INTC")
      (stock "NASDAQ" "AAOI")
      (macro "EURUSD=X" "EURUSD" "FX:EURUSD" // {decimals = 4;})
      (macro "^VIX" "VIX" "CBOE:VIX")
      (macro "GC=F" "GOLD" "COMEX:GC1!")
      (macro "CL=F" "OIL" "NYMEX:CL1!")
      (macro "^GSPC" "SPX" "SP:SPX")
      (macro "^NDX" "NDX" "NASDAQ:NDX")
    ]);
in {
  programs.sketchybar = {
    enable = true;
    inherit luaPackage;
  };

  # `extraPackages` only reaches Sketchybar's PATH. A font in home.packages is
  # linked into ~/Library/Fonts/HomeManager, where macOS finds it.
  home.packages = [pkgs.sketchybar-app-font];

  # Holds Herdr's socket open and triggers the `herdr_agents` event, so the item
  # is pushed rather than polled. Runs as a LaunchAgent because SbarLua cannot
  # keep a socket of its own; it survives Herdr restarts by reconnecting.
  launchd.agents.herdr-sketchybar = {
    enable = config.programs.sketchybar.enable;
    config = {
      ProgramArguments = [(lib.getExe herdrSketchybar)];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/herdr-sketchybar.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/herdr-sketchybar.err.log";
    };
  };

  # Holds Fastmail's JMAP event stream open and triggers the `mail_unread` event.
  launchd.agents.mail-sketchybar = {
    enable = config.programs.sketchybar.enable && config.programs.rbw.enable;
    config = {
      ProgramArguments = [(lib.getExe mailSketchybar)];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/mail-sketchybar.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/mail-sketchybar.err.log";
    };
  };

  # Holds an Infura `newHeads` subscription open and triggers the `gas_price` event.
  launchd.agents.gas-sketchybar = {
    enable = config.programs.sketchybar.enable && config.programs.rbw.enable;
    config = {
      ProgramArguments = [(lib.getExe gasSketchybar)];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/gas-sketchybar.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/gas-sketchybar.err.log";
    };
  };

  # Holds Binance's and Yahoo Finance's price streams open and triggers the
  # `market_update` event.
  launchd.agents.market-sketchybar = {
    enable = config.programs.sketchybar.enable;
    config = {
      ProgramArguments = [(lib.getExe marketSketchybar) markets];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/market-sketchybar.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/market-sketchybar.err.log";
    };
  };

  programs.aerospace.settings.exec-on-workspace-change = lib.mkIf (config.programs.aerospace.enable && config.programs.sketchybar.enable) [
    "/bin/bash"
    "-c"
    "${sketchybarExe} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
  ];

  xdg.configFile = {
    "sketchybar" = {
      enable = config.programs.sketchybar.enable;
      force = true;
      source = ../dotfiles/sketchybar;
      recursive = true;
      onChange = ''
        /bin/launchctl kickstart -k "gui/$UID/org.nix-community.home.sketchybar" 2>/dev/null || true
      '';
    };
    "sketchybar/sketchybarrc" = {
      enable = config.programs.sketchybar.enable;
      executable = true;
      force = true;
      text = ''
        #!/usr/bin/env ${lib.getExe config.programs.sketchybar.luaPackage}
        SKETCHYBAR_BIN = "${sketchybarExe}"
        HERDR_BIN = "${lib.getExe herdrPackage}"
        MARKETS = "${markets}"
        MARKET_DOTS = "${marketDots}"
        -- vars.font in flake.nix, shared with Ghostty, Zed and sottomano.
        FONT = "${vars.font.name}"
        require("init")
      '';
    };
  };
}
