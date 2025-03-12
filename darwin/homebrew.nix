{...}: {
  environment.variables.HOMEBREW_NO_ANALYTICS = "1";

  services.sketchybar.enable = true;

  # TODO
  # osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Hammerspoon.app", hidden:true}' > /dev/null

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
      "burp-suite"
      "cursor"
      "datagrip"
      "docker"
      "ghostty@tip"
      "hammerspoon"
      "ledger-live"
      "mongodb-compass"
      "openvpn-connect"
      "postman"
      "raycast"
      "redis-insight"
      "shottr"
      "sloth"
      "the-unarchiver"
      "yaak"
      # "betterdisplay"
      # "bettertouchtool"
      # "chatwise"
      # "db-browser-for-sqlite"
      # "lunar"
      # "protonvpn"
      # "spotmenu"
      # "zen-browser"
    ];
    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];
  };
}
