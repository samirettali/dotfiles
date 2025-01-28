{...}: {
  environment.variables.HOMEBREW_NO_ANALYTICS = "1";

  services.aerospace = {
    enable = false;
    settings = {
      start-at-login = false;
      enable-normalization-flatten-containers = false;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 30;
    };
  };

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
      "ghostty"
      "karabiner-elements"
      "ledger-live"
      "lunar"
      "openvpn-connect"
      "phantomjs"
      "protonvpn"
      "raycast"
      "redisinsight"
      "shottr"
      "spotmenu"
      "the-unarchiver"
      # "datagrip"
      # "docker"
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
