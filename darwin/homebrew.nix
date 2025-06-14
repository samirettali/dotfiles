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
      "lm-studio"
      "maccy"
      "shottr"
      "sloth"
      "sol"
      # "the-unarchiver"
      # "burp-suite"
      # "flashspace"
      # "hyperkey"
      # "leader-key"
      # "ledger-live"
      # "mouseless"
      # "orbstack"
      # "yaak"
      # "loop"
    ];
    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];
  };
}
