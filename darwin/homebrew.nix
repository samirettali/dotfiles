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
      "choose-gui"
      "displayplacer"
      {
        name = "FelixKratz/formulae/svim";
        restart_service = "changed";
      }
    ];
    casks = [
      "docker-desktop"
      "eqmac"
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
      "FelixKratz/formulae"
    ];
  };
}
