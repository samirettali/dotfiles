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
      "terraform"
      "amazon-ecs-cli"
      "granted"
    ];
    casks = [
      "alfred"
      "another-redis-desktop-manager"
      "burp-suite"
      "datagrip"
      "rider"
      "goland"
      "docker"
      "iina"
      "karabiner-elements"
      "ledger-live"
      "logitech-options"
      "maccy"
      "mongodb-compass"
      "openvpn-connect"
      "postman"
      "protonvpn"
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
      "common-fate/granted"
    ];
  };

  programs.gnupg.agent.enable = true; # TODO is this needed?
}

