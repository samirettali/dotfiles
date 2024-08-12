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
      "terraform"
      "amazon-ecs-cli"
      "granted"
    ];
    casks = [
      "phantomjs"
      "alfred"
      "another-redis-desktop-manager"
      "burp-suite"
      "redisinsight"
      "docker"
      "iina"
      "karabiner-elements"
      "ledger-live"
      "logitech-options"
      "maccy"
      "mongodb-compass"
      "openvpn-connect"
      "postman"
      "protonvpn"
      "rectangle"
      "royal-tsx"
      "shottr"
      "slack"
      "spotmenu"
      "raycast"
      "the-unarchiver"
      "db-browser-for-sqlite"
    ];
    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "common-fate/granted"
      "nikitabobko/tap"
    ];
  };
}

