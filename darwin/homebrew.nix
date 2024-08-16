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
    ];

    casks = [
      "burp-suite"
      "cursor"
      "db-browser-for-sqlite"
      "docker"
      "docker"
      "iina"
      "karabiner-elements"
      "ledger-live"
      # "logi-options-plus" # TODO
      "maccy"
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
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];
  };
}
