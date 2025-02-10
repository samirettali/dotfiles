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
      "datagrip"
      "db-browser-for-sqlite"
      "docker"
      "ghostty"
      "karabiner-elements"
      "ledger-live"
      "lunar"
      "mongodb-compass"
      "openvpn-connect"
      "phantomjs"
      "postman"
      "protonvpn"
      "raycast"
      "redis-insight"
      "shottr"
      "spotmenu"
      "the-unarchiver"
      "zen-browser"
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];
  };
}
