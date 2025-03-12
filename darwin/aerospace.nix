{pkgs, ...}: {
  programs.aerospace = {
    enable = true;
    userSettings = {
      start-at-login = true;
      accordion-padding = 30;
      automatically-unhide-macos-hidden-apps = false;

      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "${pkgs.sketchybar}/bin/sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE label.color=0xffffffff && /run/current-system/sw/bin/sketchybar --set space.$AEROSPACE_PREV_WORKSPACE label.color=0x30ffffff"
      ];
      default-root-container-layout = "tiles"; # TODO: this is not working
      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 8;
        outer.bottom = 8;
        outer.right = 8;
        outer.top = [
          {
            monitor = {
              "^built-in retina display$" = 10;
            };
          }
          48
        ];
      };
      mode.main.binding = {
        cmd-h = [];
        cmd-alt-h = [];

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-f = "fullscreen";
        alt-e = "layout tiles accordion";
        alt-shift-space = "layout floating tiling";

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

        alt-ctrl-h = "resize width -50";
        alt-ctrl-j = "resize height +50";
        alt-ctrl-k = "resize height -50";
        alt-ctrl-l = "resize width +50";
        alt-shift-minus = "resize smart -100";
        alt-shift-equal = "resize smart +100";

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
      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "main";
        "6" = "main";
        "7" = "main";
        "8" = "main";
        "9" = "main";
        "10" = "secondary";
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
            window-title-regex-substring = "Backpack";
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
}
