{
  font,
  ...
}: let
  modifier = "Mod4"
{
  wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      config = rec {
          bars = [
              {
                fonts = {
                    names = [ "${font}" ];
                    style = "Regular";
                    size = 10.0;
                };
                statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${homeDirectory}/.config/i3status-rust/config-default.toml";
                trayOutput = "primary";
                mode = "dock";
                position = "top";
              }
          ];
          floating = {
              criteria = [
                  { class = "Pavucontrol"; }
                  { class = "nemo"; }
                  { window_role = "pop-up"; }
                  { window_role = "task_dialog"; }
              ];
          };
          focus.followMouse = true;
          fonts = {
              names = [ "${font}" ];
              style = "Regular";
              size = 10.0;
          };
          gaps = {
              inner = 0;
              outer = 0;
              smartBorders = "on";
          };
          input = {
              "*" = {
                  xkb_layout = "us,it";
                  repeat_delay = "200";
                  repeat_rate = "60";
              };
          };
          keybindings = {
                  "${modifier}+Shift+c" = "kill";
                  "${modifier}+Shift+r" = "reload";
                  "${modifier}+Shift+q" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
                  "${modifier}+Tab" = "workspace back_and_forth";
                  "${modifier}+Return" = "exec ${pkgs.foot}/bin/foot";
                  "${modifier}+p" = "exec ${pkgs.bemenu}/bin/bemenu-run";
                  "${modifier}+x" = "exec ${pkgs.cinnamon.nemo}/bin/nemo";
                  "${modifier}+y" = "exec ${pkgs.hyprpicker}/bin/hyprpicker | wl-copy";
                  "Mod4+BackSpace" = "exec swaymsg input type:keyboard xkb_switch_layout next";
                  "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
                  "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
          };
          modifier = "${modifier}";
          output = {
            "*" = {
                  bg = "/home/samir/pics/walls/oxomfy9gqwgb1.jpg fill";
              };
          };
          startup = [
              { command = "nm-applet";}
              { command = "wl-paste --watch cliphist store"; }
              { command = "xrdb -merge ~/.Xresources"; }
              { command = "mako"; }
              { command = "kanshi"; always = true; }
              { command = "exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
          ];
          terminal = "foot";
          window = {
              border = 4;
              titlebar = false;
          };
          workspaceAutoBackAndForth = true;
      };
  };
}
