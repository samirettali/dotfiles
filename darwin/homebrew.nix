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
      "cursor"
      "docker"
      "eqmac"
      "ghostty@tip" # TODO: use `programs.ghostty.enable = true;` when darwin build is fixed
      "hammerspoon"
      "maccy"
      "shottr"
      "sloth"
      "sol"
      # "burp-suite"
      # "flashspace"
      # "hyperkey"
      # "leader-key"
      # "ledger-live"
      # "lm-studio"
      # "loop"
      # "mouseless"
      # "orbstack"
      # "the-unarchiver"
      # "yaak"
    ];
    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];
  };
}
