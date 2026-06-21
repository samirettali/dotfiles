{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    zsh.enable = false;
    gnupg.agent.enable = true; # TODO is this needed?
    fish = {
      enable = true;
      useBabelfish = true;
    };
  };

  networking = {
    hostName = "mbp";
    knownNetworkServices = ["Wi-Fi"];
    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  services = {
    tailscale.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  environment = {
    shells = [
      config.programs.fish.package
    ];

    systemPackages = with pkgs; [
      duti
    ];
  };

  time.timeZone = "Europe/Rome";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.activationScripts.postActivation.text = lib.mkAfter (let
    user = config.system.primaryUser;
    firefoxBundleId = "org.mozilla.firefox";
  in ''
    user_home="$(/usr/bin/dscl . -read /Users/${user} NFSHomeDirectory | /usr/bin/awk '{print $2}')"
    user_uid="$(/usr/bin/id -u ${user})"
    user_cmd=(/bin/launchctl asuser "$user_uid" /usr/bin/sudo -u ${user} --set-home)

    # Register Firefox from Home Manager's app bundle and make it the default browser.
    firefox_app="$(${pkgs.findutils}/bin/find "$user_home/Applications" -maxdepth 3 -name Firefox.app -print -quit 2>/dev/null || true)"
    if [ -n "$firefox_app" ]; then
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$firefox_app"
    fi

    # macOS may reject programmatic browser changes until the user approves the
    # Firefox default-browser prompt once, so keep this best-effort.
    "''${user_cmd[@]}" ${lib.getExe pkgs.duti} -s ${firefoxBundleId} http || true
    "''${user_cmd[@]}" ${lib.getExe pkgs.duti} -s ${firefoxBundleId} https || true

  '');

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults = {
      WindowManager = {
        EnableStandardClickToShowDesktop = false;
        StandardHideWidgets = true;
        StageManagerHideWidgets = true;
      };
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        mru-spaces = false; # Don't rearrange spaces based on most recently used
        expose-group-apps = true; # for aerospace it should be set to true
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
        ShowStatusBar = false;
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
        _HIHideMenuBar = false;
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
        # NSMenuEnableActionImages = false; # TODO: wait for PR to be merged
        "com.apple.mouse.tapBehavior" = null;
        "com.apple.swipescrolldirection" = false;
        "com.apple.trackpad.scaling" = 3.0;
        # TODO
        # AppleLanguages = [
        #   "en-US"
        #   "it-IT"
        # ];
        # AppleLocale = "en_US";
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

      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "60" = {enabled = false;}; # Disable "Select the previous input source" (Ctrl+Space)
            "61" = {enabled = false;}; # Disable "Select next source in input menu" (Ctrl+Option+Space)
            "64" = {enabled = false;}; # Disable Spotlight
          };
        };
      };
    };
  };
}
