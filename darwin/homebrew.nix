{ ... }: {
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
