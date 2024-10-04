{pkgs, ...}: {
  programs = {
    zsh.enable = true;
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
    nix-daemon.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = ["JetBrainsMono"];
      })
    ];
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
    };
    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        mru-spaces = false; # Don't rearrange spaces based on most recently used
        launchanim = false;
        expose-animation-duration = 0.1;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "icnv";
        QuitMenuItem = true;
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
        NSWindowShouldDragOnGesture = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.swipescrolldirection" = false;
        "com.apple.trackpad.scaling" = 3.0;
      };
      LaunchServices = {
        LSQuarantine = false;
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
        hotkey=$((117 + $i))
        value=$((48 + $i))
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
    /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist

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
