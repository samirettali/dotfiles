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
      "eqmac"
      "ghostty@tip"
      "hammerspoon"
      "maccy"
      "orbstack"
      "shottr"
      "sloth"
      "sol"
      "the-unarchiver"
      # "hyperkey"
      # "leader-key"
      # "ledger-live"
      # "mouseless"
      # "yaak"
    ];
    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];
  };
}
