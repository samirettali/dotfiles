{...}: {
  environment.variables.HOMEBREW_NO_ANALYTICS = "1";

  # TODO: installing sketchybar this way doesn't work with aerospace
  services.sketchybar.enable = false;

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
      "displayplacer"
      "sketchybar"
    ];
    casks = [
      "burp-suite"
      "cursor"
      "docker"
      "font-sketchybar-app-font"
      "ghostty@tip"
      "hammerspoon"
      "hyperkey"
      "leader-key"
      "ledger-live"
      "raycast"
      "shottr"
      "sloth"
      "sol"
      "the-unarchiver"
      "yaak"
      "zen-browser"
    ];
    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "FelixKratz/formulae"
    ];
  };
}
