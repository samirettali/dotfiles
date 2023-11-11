{ pkgs
, homeDirectory
, font
, nixpkgs
, ...
}:
let
  modifier = "Mod4";
in
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      assigns = {
        "8" = [{ app_id = "org.keepassxc.KeePassXC"; }];
      };
      bars = [
        {
          fonts = {
            names = [ "${font}" ];
            style = "Regular";
            size = 10.0;
          };
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${homeDirectory}/.config/i3status-rust/config-default.toml";
          trayOutput = "DP-1";
          mode = "dock";
          position = "top";
        }
      ];
      floating = {
        criteria = [
          { app_id = "pavucontrol"; }
          { app_id = "nemo"; }
          { app_id = "floating_term"; }
          { window_role = "pop-up"; }
          { window_role = "task_dialog"; }
          { title = "Steam - Update News"; }
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
        smartGaps = true;
      };
      input = {
        "*" = {
          xkb_layout = "us,it";
          repeat_delay = "200";
          repeat_rate = "60";
        };
      };
      keybindings = nixpkgs.lib.mkOptionDefault {
        "${modifier}+Shift+c" = "kill";
        "${modifier}+Shift+r" = "reload";
        "${modifier}+Shift+q" = "exec swaynag -t warning -m 'Do you want to exit?' -b 'Yes' 'swaymsg exit'";
        "${modifier}+Tab" = "workspace back_and_forth";
        "${modifier}+BackSpace" = "exec swaymsg input type:keyboard xkb_switch_layout next";
        "${modifier}+t" = "layout tabbed";
        "${modifier}+Return" = "exec ${pkgs.foot}/bin/foot";
        "${modifier}+s" = "exec scratchpad";
        "${modifier}+d" = "exec ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu=bemenu";
        "${modifier}+x" = "exec ${pkgs.cinnamon.nemo}/bin/nemo";
        "${modifier}+Shift+v" = "exec ${pkgs.cliphist}/bin/cliphist list | ${pkgs.bemenu}/bin/bemenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";
        "${modifier}+y" = "exec ${pkgs.hyprpicker}/bin/hyprpicker | ${pkgs.wl-clipboard}/bin/wl-copy";
        "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
        "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
      };
      modifier = "${modifier}";
      output = {
        "*" = {
          bg = "/home/samir/pics/walls/oxomfy9gqwgb1.jpg fill";
          max_render_time = "1";
        };
      };
      startup = [
        { command = "${pkgs.networkmanagerapplet}/bin/nm-applet"; }
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store"; }
        { command = "${pkgs.mako}/bin/mako"; }
        { command = "exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
      ];
      terminal = "foot";
      window = {
        border = 2;
        titlebar = false;
      };
      workspaceAutoBackAndForth = true;
    };
    xwayland = true;
  };

  programs = {
    i3status-rust = {
      enable = true;
      bars = {
        default = {
          blocks = [
            { block = "battery"; }
            {
              block = "memory";
              format = " MEM $mem_total_used_percents ";
              format_alt = " MEM $mem_used_percents $buffers_percent $cached_percent ";
            }
            {
              block = "keyboard_layout";
              driver = "sway";
              mappings = {
                "English (US)" = "us";
                "Italian" = "it";
              };
            }
            { block = "sound"; }
            {
              block = "time";
              format = " $timestamp.datetime(f:'%a %d/%m %R') ";
              interval = 1;
            }
          ];
          settings = {
            theme = {
              theme = "plain";
              # overrides = {
              #   idle_bg = "#000000";
              #   idle_fg = "#ffffff";
              # };
            };
          };
        };
      };
    };
    swaylock = {
      enable = true;
      settings = {
        color = "808080";
        font-size = 24;
        indicator-idle-visible = false;
        indicator-radius = 100;
        line-color = "ffffff";
        show-failed-attempts = true;
      };
    };
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    BEMENU_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CURRENT_DESKTOP = "sway";
  };
}
