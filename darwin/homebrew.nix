{...}: {
  environment.variables.HOMEBREW_NO_ANALYTICS = "1";

  services.aerospace = {
    enable = true;
    settings = {
      start-at-login = false;
      enable-normalization-flatten-containers = false;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 30;
      # exec-on-workspace-change = ["/bin/bash", "-c", "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE" ];

      default-root-container-layout = "tiles"; # TODO: this is not working
      # gaps = {
      #   inner.horizontal = 8;
      #   inner.vertical = 8;
      #   outer.left = 8;
      #   outer.bottom = 8;
      #   outer.right = 8;
      #   outer.top = 8;
      # };
      mode.main.binding = {
        # alt-enter = "exec-and-forget /etc/profiles/per-user/s.ettali/bin/alacritty"; # TODO: fix this

        cmd-h = []; # Disable "hide application"
        cmd-alt-h = []; # Disable "hide others"

        alt-shift-f = "exec-and-forget open -a Finder.app";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-v = "split vertical";
        alt-b = "split horizontal";
        alt-f = "fullscreen";
        alt-e = "layout tiles horizontal vertical";
        alt-shift-space = "layout floating tiling";

        alt-shift-minus = "resize smart -100";
        alt-shift-equal = "resize smart +100";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-0 = "workspace 10";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-0 = "move-node-to-workspace 10";

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
        alt-shift-q = "close";

        alt-comma = "focus-monitor --wrap-around next";
        alt-shift-comma = "move-node-to-monitor --wrap-around next";

        # TODO: this is not working
        # alt-r = 'mode resize';
        #
        # [mode.resize.binding];
        # h = 'resize width -50';
        # j = 'resize height +50';
        # k = 'resize height -50';
        # l = 'resize width +50';
        # enter = 'mode main';
        # esc = 'mode main';

        alt-shift-semicolon = "mode service";
      };
      mode.service.binding = {
        esc = ["reload-config" "mode main"];
        r = ["flatten-workspace-tree" "mode main"];
        alt-shift-h = ["join-with left" "mode main"];
        alt-shift-j = ["join-with down" "mode main"];
        alt-shift-k = ["join-with up" "mode main"];
        alt-shift-l = ["join-with right" "mode main"];
      };
      on-window-detected = [
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.google.Chrome";
            window-title-regex-substring = "Picture-in-picture";
          };
          run = ["layout floating"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.apple.finder";
          };
          run = ["layout floating"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "cc.ffitch.shottr";
          };
          run = ["layout floating"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.hnc.discord";
          };
          run = ["move-node-to-workspace 7"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.spotify.client";
          };
          run = ["move-node-to-workspace 8"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "org.keepassxc.KeePassXC";
          };
          run = ["move-node-to-workspace 8"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.hnc.discord";
          };
          run = ["move-node-to-workspace 8"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.google.Chrome";
            window-title-regex-substring = "Rabby Wallet";
          };
          run = ["layout floating"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.google.Chrome";
            window-title-regex-substring = "^Keplr";
          };
          run = ["layout floating"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.google.Chrome";
            window-title-regex-substring = "^Phantom Wallet";
          };
          run = ["layout floating"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.google.Chrome";
            window-title-regex-substring = "^Coinbase Wallet";
          };
          run = ["layout floating"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.google.Chrome";
            window-title-regex-substring = "^MetaMask";
          };
          run = ["layout floating"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.google.Chrome";
            window-title-regex-substring = "^Zerion";
          };
          run = ["layout floating"];
        }
      ];
    };
  };

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
      "displayplacer"
      "stunnel"
    ];

    casks = [
      "betterdisplay"
      "bettertouchtool"
      "burp-suite"
      "datagrip"
      "db-browser-for-sqlite"
      "docker"
      "ghostty"
      "karabiner-elements"
      "ledger-live"
      "lunar"
      "mongodb-compass"
      "openvpn-connect"
      "postman"
      "protonvpn"
      "raycast"
      "redis-insight"
      "shottr"
      "spotmenu"
      "the-unarchiver"
      "zen-browser"
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];
  };
}
