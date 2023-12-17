{ pkgs
, homeDirectory
, font
, nixpkgs
, terminal
, ...
}:
let
  modifier = "Mod4";
in
{
  home.packages = with pkgs; [
    bemenu
  ];

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
          { app_id = "org.keepassxc.KeePassXC"; }
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
        "${modifier}+t" = "layout tabbed";
        "${modifier}+e" = null;
        "${modifier}+Tab" = "workspace back_and_forth";
        "${modifier}+BackSpace" = "exec swaymsg input type:keyboard xkb_switch_layout next";
        "${modifier}+Shift+q" = "exec swaynag -t warning -m 'Do you want to exit?' -b 'Yes' 'swaymsg exit'";

        "${modifier}+s" = "exec scratchpad";
        "${modifier}+d" = "exec j4-dmenu-desktop --dmenu=bemenu";
        "${modifier}+p" = "exec passbemenu";
        "${modifier}+x" = "exec nemo";
        "${modifier}+y" = "exec hyprpicker | wl-copy";
        "${modifier}+Return" = "exec ${terminal}";
        "XF86AudioRaiseVolume" = "exec pamixer -i 5";
        "XF86AudioLowerVolume" = "exec pamixer -d 5";
      };
      modifier = "${modifier}";
      output = {
        "*" = {
          bg = "/home/samir/pics/walls/oxomfy9gqwgb1.jpg fill";
          max_render_time = "1";
        };
      };
      startup = [
        { command = "nm-applet"; }
        { command = "wl-paste --watch cliphist store"; }
        { command = "mako"; }
        { command = "exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK"; }
      ];
      terminal = terminal;
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
    # BEMENU_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CURRENT_DESKTOP = "sway";
    BEMENU_OPTS = "--center --accept-single -W 0.3 --binding vim --vim-esc-exits -l 10 --fn '${font} 14' -p '' --border 2 --ignorecase --wrap --fixed-height";
  };
}

