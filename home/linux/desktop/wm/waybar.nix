{ outputs, config, lib, pkgs, ... }:

let
  hasSway = config.wayland.windowManager.sway.enable;
  sway = config.wayland.windowManager.sway.package;
  hasHyprland = config.wayland.windowManager.hyprland.enable;
  hyprland = config.wayland.windowManager.hyprland.package;
in
{
  systemd.user.services.waybar = {
    Unit.StartLimitBurst = 30;
  };
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or  [ ]) ++ [ "-Dexperimental=true" ];
    });
    systemd.enable = true;
    settings = {
      primary = {
        mode = "dock";
        layer = "top";
        height = 30;
        margin = "0";
        position = "top";

        modules-left = [
          "custom/menu"
        ] ++ (lib.optionals hasSway [
          "sway/workspaces"
          "sway/mode"
        ]) ++ (lib.optionals hasHyprland [
          "hyprland/workspaces"
          "hyprland/submap"
        ]);

        modules-center = [
          "clock"
        ];

        modules-right = (lib.optionals hasHyprland [
          "hyprland/language"
        ]) ++ [
          "pulseaudio"
          "battery"
          "tray"
        ];

        clock = {
          interval = 1;
          format = "{:%d/%m %H:%M:%S}";
          tooltip-format = ''
            <tt><big>{calendar}</big></tt>'';
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " ";
          format-icons = {
            headphone = "󰋋";
            headset = "󰋎";
            portable = "";
            default = [ "" "" "" ];
          };
          # on-click = pavucontrol;
        };

        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          onclick = "";
        };

        "hyprland/language" = {
          "format-en" = "us";
          "format-it" = "it";
        };
      };
    };
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    # font-family: ${config.fontProfiles.regular.family}, ${config.fontProfiles.monospace.family};
    # style = let inherit (config.colorscheme) colors; in /* css */ ''
    style =
      let
        colors = {
          black = "000000";
          base04 = "928374";
          white = "bdbdbd";
          blue = "285577";
        };
      in
      ''
        * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 12pt;
          border-radius: 0;
          padding: 0;
        }

        #mode, #battery, #pulseaudio, #language, #tray {
            padding: 0 10px;
        }

        window#waybar {
          background-color: #${colors.black};
          color: #${colors.white};
        }

        #workspaces button {
          color: #${colors.white};
          padding: 4px;
        }
        #workspaces button.hidden {
          color: #${colors.base04};
        }
        #workspaces button.focused,
        #workspaces button.active {
          background-color: #${colors.white};
          color: #${colors.black};
        }
      '';
  };
}



