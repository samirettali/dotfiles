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
        persistent-apps = [
          "/Applications/Google Chrome.app"
          "/Applications/Ghostty.app"
          "~/Applications/Slack.app"
        ];
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
        spans-displays = false; # TODO: set to true for aerospace
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
        "com.apple.mouse.tapBehavior" = 1;
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

  launchd = {
    user = {
      agents = {
        ollama = {
          command = "${pkgs.ollama}/bin/ollama serve";
          serviceConfig = {
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/tmp/ollama.log";
            StandardErrorPath = "/tmp/ollama.error.log";
          };
        };
      };
    };
  };

  system.activationScripts.postActivation.text = ''
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict

    # Switch to Desktop $i (Option + $i)
    for i in {1..9}; do
        hotkey=$((117 + i))
        value=$((48 + i))
        /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$hotkey dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist
        /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$hotkey:enabled bool true" ~/Library/Preferences/com.apple.symbolichotkeys.plist
        /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$hotkey:value dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist
        /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$hotkey:value:type string standard" ~/Library/Preferences/com.apple.symbolichotkeys.plist
        /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$hotkey:value:parameters array" ~/Library/Preferences/com.apple.symbolichotkeys.plist
        /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$hotkey:value:parameters: integer $value" ~/Library/Preferences/com.apple.symbolichotkeys.plist
        /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$hotkey:value:parameters: integer 1" ~/Library/Preferences/com.apple.symbolichotkeys.plist
        /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$hotkey:value:parameters: integer 524288" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    done

    # Map Cmd+Shift+L to change language
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:61 dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:61:enabled bool true" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:61:value dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:61:value:type string standard" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:61:value:parameters array" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:61:value:parameters: integer 76" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:61:value:parameters: integer 37" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:61:value:parameters: integer 1179648" ~/Library/Preferences/com.apple.symbolichotkeys.plist

    # Disable Ctrl+Space for previous input source
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:60 dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:60:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist

    # Disable Cmd+Space for Spotlight
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64 dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64:enabled bool" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    # TODO: use this
    # /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    #     -c "Delete :AppleSymbolicHotKeys:65" \
    #     -c "Add :AppleSymbolicHotKeys:65:enabled bool false" \
    #     -c "Add :AppleSymbolicHotKeys:65:value:parameters array" \
    #     -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 65535" \
    #     -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 49" \
    #     -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 1572864" \
    #     -c "Add :AppleSymbolicHotKeys:65:type string standard"

    # Disable Cmd+Shift+4 for screenshot to clipboard
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:31 dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:31:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist

    # Disable Cmd+Shift+5 for screenshot and recording options
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:28 dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:28:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist

    # Disable Cmd+M for minimize
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:77 dict" ~/Library/Preferences/com.apple.symbolichotkeys.plist
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:77:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
  '';
}
