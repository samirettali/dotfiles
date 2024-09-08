{pkgs, ...}: {
  environment.variables.HOMEBREW_NO_ANALYTICS = "1";

  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    brews = [
      "autoconf"
      "automake"
      "cmake"
      "coreutils"
      "displayplacer"
      "git-delta"
      "sketchybar"
    ];

    casks = [
      "amethyst"
      "aerospace"
      "burp-suite"
      "cursor"
      "db-browser-for-sqlite"
      "docker"
      "iina"
      "karabiner-elements"
      "ledger-live"
      "mongodb-compass"
      "openvpn-connect"
      "phantomjs"
      "postman"
      "protonvpn"
      "raycast"
      "rectangle"
      "redisinsight"
      "shottr"
      "spotmenu"
      "the-unarchiver"
      "zed"
      # "logi-options-plus" # TODO
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];
  };

  launchd = {
    user = {
      agents = {
        ollama = {
          command = "${pkgs.ollama}/bin/ollama serve";
          serviceConfig = {
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/tmp/ollama.log";
            StandardErrorPath = "/tmp/ollama.error.log";
          };
        };
      };
    };
  };
}
