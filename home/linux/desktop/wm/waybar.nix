{
  lib,
  config,
  pkgs,
  ...
}: let
  hasSway = config.wayland.windowManager.sway.enable;
  sway = config.wayland.windowManager.sway.package;
  hasHyprland = config.wayland.windowManager.hyprland.enable;
  hyprland = config.wayland.windowManager.hyprland.package;
in {
  systemd.user.services.waybar = {
    Unit.StartLimitBurst = 30;
  };
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      primary = {
        mode = "dock";
        layer = "top";
        height = 32;
        margin = "0";
        position = "top";

        modules-left =
          [
            "custom/menu"
          ]
          ++ (lib.optionals hasSway [
            "sway/workspaces"
            "sway/mode"
          ])
          ++ (lib.optionals hasHyprland [
            "hyprland/workspaces"
            "hyprland/submap"
          ]);

        modules-center = [
          "clock"
        ];

        modules-right =
          (lib.optionals hasHyprland [
            "hyprland/language"
          ])
          ++ [
            "wireplumber"
            "battery"
            "tray"
          ];

        clock = {
          interval = 1;
          format = "{:%d/%m %H:%M:%S}";
        };

        wireplumber = {
          format = "{icon} {volume}%";
          format-muted = "";
          format-icons = {
            headphone = "󰋋";
            headset = "󰋎";
            portable = "";
            default = ["" "" ""];
          };
          on-click = lib.getExe pkgs.pavucontrol;
        };
        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          onclick = "";
        };
        "hyprland/language" = {
          format-en = "󰌌 us";
          format-it = "󰌌 it";
        };
        tray = {
          spacing = 10;
          reverse-direction = true;
        };
      };
    };
    style = let
      colors = {
        black = "#000000";
        white = "#bbbbbb";
      };
    in ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 11pt;
        border-radius: 0;
        padding: 0;
        margin: 0;
      }

      #battery, #wireplumber, #language, #tray {
          padding: 0 10;
          margin: 0 0;
      }

      window#waybar {
        background-color: ${colors.black};
        color: ${colors.white};
      }

      #workspaces button {
        color: ${colors.white};
        padding: 4px;
      }

      #workspaces button.focused,
      #workspaces button.active {
        background-color: ${colors.white};
        color: ${colors.black};
      }
    '';
  };
}
