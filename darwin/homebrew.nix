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
      "choose-gui"
      "displayplacer"
    ];
    casks = [
      "burp-suite"
      "cursor"
      "ghostty@tip"
      "hammerspoon"
      "orbstack"
      "raycast"
      "shottr"
      "sloth"
      "the-unarchiver"
      "zen-browser"
      # "leader-key"
      # "hyperkey"
      # "ledger-live"
      # "mouseless"
      # "sol"
      # "yaak"
    ];
    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];
  };
}
