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
      "alfred"
      "burp-suite"
      "cursor"
      "docker"
      "db-browser-for-sqlite"
      "docker"
      "iina"
      "karabiner-elements"
      "ledger-live"
      "logitech-options"
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

