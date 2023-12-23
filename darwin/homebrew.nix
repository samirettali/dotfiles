{ ... }: {
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
      "lua"
      "openjdk"
      "terraform"
    ];
    casks = [
      "alfred"
      "another-redis-desktop-manager"
      "burp-suite"
      "docker"
      "karabiner-elements"
      "ledger-live"
      "rectangle"
      "logitech-options"
      "maccy"
      "mongodb-compass"
      "postman"
      "rectangle"
      "royal-tsx"
      "shottr"
      "slack"
      "spotmenu"
      "the-unarchiver"
    ];
    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];
  };

  programs.gnupg.agent.enable = true; # TODO is this needed?
}

