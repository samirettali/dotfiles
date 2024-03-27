{ lib, config, pkgs, ... }:
let
  modifier = "Mod4";
in
{

  wayland.windowManager.sway = {
    enable = false;
    wrapperFeatures.gtk = true;
    config = {
      assigns = {
        "8" = [{ app_id = "spotify"; }];
      };
      bars = [
        {
          fonts = {
            names = [ "JetBrainsMono Nerd Font" ];
            style = "Regular";
            size = 10.0;
          };
          trayOutput = "DP-1";
          mode = "dock";
          position = "top";
        }
      ];
      floating = {
        criteria = [
          { app_id = "pavucontrol"; }
          { app_id = "nemo"; }
          { app_id = "org.keepassxc.KeePassXC"; }
          { app_id = "floating_term"; }
          { window_role = "pop-up"; }
          { window_role = "task_dialog"; }
        ];
      };
      focus.followMouse = true;
      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        style = "Regular";
        size = 10.0;
      };
      gaps = {
        inner = 0;
        outer = 0;
        smartBorders = "on";
        smartGaps = true;
      };
      input = {
        "*" = {
          xkb_layout = "us,it";
          repeat_delay = "200";
          repeat_rate = "60";
        };
      };
      keybindings = lib.mkOptionDefault {
        "${modifier}+Shift+c" = "kill";
        "${modifier}+Shift+r" = "reload";
        "${modifier}+t" = "layout tabbed";
        "${modifier}+Tab" = "workspace back_and_forth";
        "${modifier}+BackSpace" = "exec swaymsg input type:keyboard xkb_switch_layout next";
        "${modifier}+Shift+q" = "exec swaynag -t warning -m 'Do you want to exit?' -b 'Yes' 'swaymsg exit'";

        "${modifier}+s" = "exec scratchpad";
        # "${modifier}+d" = "exec j4-dmenu-desktop --dmenu=bemenu";
        "${modifier}+d" = "exec bemenu-run";
        "${modifier}+p" = "exec passbemenu";
        "${modifier}+x" = "exec nemo";
        "${modifier}+y" = "exec hyprpicker | wl-copy";
        "${modifier}+Return" = "exec alacritty";
        "${modifier}+Shift+v" = "exec cliphist list | bemenu | cliphist decode | wl-copy";
        "XF86AudioRaiseVolume" = "exec pamixer -i 5";
        "XF86AudioLowerVolume" = "exec pamixer -d 5";
      };
      modifier = "${modifier}";
      output = {
        "*" = {
          bg = "/home/samir/pics/walls/oxomfy9gqwgb1.jpg fill"; # TODO save image in repo
          max_render_time = "1";
        };
      };
      startup = [
        { command = "nm-applet"; }
        { command = "wl-paste --watch cliphist store"; }
        { command = "mako"; }
        { command = "exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
      ];
      terminal = "alacritty";
      window = {
        border = 2;
        titlebar = false;
      };
      workspaceAutoBackAndForth = true;
    };
    xwayland = true;
  };
}

