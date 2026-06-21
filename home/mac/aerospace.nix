{
  lib,
  pkgs,
  ...
}: {
  programs.aerospace = {
    enable = true;
    settings = {
      start-at-login = true;
      accordion-padding = 30;
      automatically-unhide-macos-hidden-apps = false;

      default-root-container-layout = "tiles"; # TODO: this is not working
      gaps = {
        inner.horizontal = 0;
        inner.vertical = 0;
        outer.left = 0;
        outer.bottom = 0;
        outer.right = 0;
        outer.top = 0;
      };
      mode.main.binding = {
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
        alt-slash = "layout tiles horizontal vertical";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";

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
      on-window-detected = [
        # TODO: https://github.com/nix-community/home-manager/commit/7f619d2a72061c24c5ef184aa9f89a4b6c6a2e70
        # workspace assignments (mirrors rift app_rules; rift is 0-indexed)
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.mitchellh.ghostty";
          };
          run = ["move-node-to-workspace 3"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.hnc.discord";
          };
          run = ["move-node-to-workspace 4"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "ru.keepcoder.Telegram";
          };
          run = ["move-node-to-workspace 4"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.spotify.client";
          };
          run = ["move-node-to-workspace 4"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.apple.Preview";
          };
          run = ["move-node-to-workspace 4"];
        }
        # floating (mirrors rift app_rules floating = true)
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.apple.calculator";
          };
          run = ["layout floating"];
        }
        {
          check-further-callbacks = true;
          "if" = {
            app-id = "com.apple.systempreferences";
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
            app-name-regex-substring = "Archive Utility";
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
            app-id = "com.riotgames.LeagueofLegends.LeagueClientUx";
          };
          run = ["layout floating"];
        }
      ];
    };
    launchd = {
      enable = true;
      keepAlive = true;
    };
  };
}
