{...}: {
  environment.variables.HOMEBREW_NO_ANALYTICS = "1";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
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
      "Hyperkey"
      "betterdisplay"
      "bettertouchtool"
      "burp-suite"
      "chatwise"
      "cursor"
      "datagrip"
      "db-browser-for-sqlite"
      "deluge"
      "docker"
      "ghostty"
      "karabiner-elements"
      "ledger-live"
      "lunar"
      "mongodb-compass"
      "openvpn-connect"
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
