{...}: {
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
    ];

    casks = [
      "amethyst"
      "burp-suite"
      "cursor"
      "db-browser-for-sqlite"
      "docker"
      "iina"
      "karabiner-elements"
      "lunar"
      "openvpn-connect"
      "phantomjs"
      "protonvpn"
      "raycast"
      "redisinsight"
      "shottr"
      "spotmenu"
      "the-unarchiver"
      "zed"
      # "ledger-live"
      # "logi-options-plus" # TODO
      # "mongodb-compass"
      # "postman"
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];
  };
}
