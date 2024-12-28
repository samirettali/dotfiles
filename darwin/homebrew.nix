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
      "stunnel"
    ];

    casks = [
      "amethyst"
      "betterdisplay"
      "bettertouchtool"
      "burp-suite"
      "cursor"
      "db-browser-for-sqlite"
      "docker"
      "ghostty"
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
      "ledger-live"
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
