{pkgs, ...}: {
  programs = {
    zsh.enable = true;
    fish.enable = true;
    gnupg.agent.enable = true; # TODO is this needed?
  };

  networking = {
    hostName = "settali";
    knownNetworkServices = ["Wi-Fi"];
    dns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  services = {
    tailscale.enable = true;
    karabiner-elements.enable = false;
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  environment.shells = [
    pkgs.fish
  ];

  time.timeZone = "Europe/Rome";

  # TODO: can this be used in the terminal? and maybe move to common config with linux
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults = {
      WindowManager.EnableStandardClickToShowDesktop = false;
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        mru-spaces = false; # Don't rearrange spaces based on most recently used
        expose-group-apps = true; # for aerospace
        launchanim = false;
        expose-animation-duration = 0.0;
        show-recents = false;
        static-only = true;
        mineffect = "scale";
        minimize-to-application = true;
        scroll-to-open = true;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = false;
        "_FXSortFoldersFirst" = true;
        "_FXSortFoldersFirstOnDesktop" = true;
        CreateDesktop = true;
        NewWindowTarget = "Home";
      };
      spaces = {
        spans-displays = false;
      };
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = 3.0;
      };
      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 1;
        ApplePressAndHoldEnabled = false;
        AppleKeyboardUIMode = 3;
        AppleShowScrollBars = "Always";
        AppleInterfaceStyle = "Dark";
        _HIHideMenuBar = true;
        NSWindowShouldDragOnGesture = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        "com.apple.mouse.tapBehavior" = null;
        "com.apple.swipescrolldirection" = false;
        "com.apple.trackpad.scaling" = 3.0;
      };
      LaunchServices = {
        LSQuarantine = false;
      };
      menuExtraClock = {
        Show24Hour = true;
        ShowSeconds = true;
      };
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
        TrackpadRightClick = true;
      };
    };
  };
}
