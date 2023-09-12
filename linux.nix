{
  home-manager,
  pkgs,
  homeDirectory,
  ...
}:

let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  font = "JetBrainsMono Nerd Font";

in {
  imports = [
    ./user/gtk.nix
  ];
  # Enabling linger makes the systemd user services start
  # automatically. In this machine, I want to trigger the
  # `gpg-forward-agent-path` service file automatically as
  # systemd starts, so the socket dir is always created and I
  # can forward the GPG agent through SSH directly without
  # having a first failed connection due to a missing
  # `/run/user/<id>/gnupg`.
  home.activation.linger = home-manager.lib.hm.dag.entryBefore ["reloadSystemd"] ''
    ${pkgs.systemd}/bin/loginctl enable-linger $USER
  '';

  # programs = {
  #   keychain = {
  #     enable = true;
  #     enableZshIntegration = true;
  #     keys = [];
  #     inheritType = "any";
  #   };
  #   zsh.shellAliases = {
  #     gpg = "${pkgs.gnupg}/bin/gpg --no-autostart";
  #   };
  # };

  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.firefox-wayland}/bin/firefox";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    BEMENU_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  }

  home.packages = with pkgs; [
    grim
    slurp
    kanshi
    wl-clipboard
    cliphist
    bemenu
    wbg
    wdisplays
    xorg.xrdb
    hyprpicker
    networkmanagerapplet

    pamixer
    trash-cli
    p7zip
    unzip

    dbus-sway-environment
    configure-gtk
    xdg-utils

    foot

    firefox-wayland
    mpv
    zathura
    cinnamon.nemo
    ffmpegthumbnailer
    webp-pixbuf-loader
    pavucontrol
    sxiv
  ];

  programs =  {
    i3status-rust = {
        enable = true;
        bars = {
            default = {
                blocks = [
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
                        overrides = {
                            idle_bg = "#000000";
                            idle_fg = "#ffffff";
                        };
                    };
                };
            };
        };
    };
  };

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
                statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.home.homeDirectory}/.config/i3status-rust/config-default.toml";
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
              # smartGaps = true;
          };
          input = {
              "*" = {
                  xkb_layout = "us,it";
                  repeat_delay = "200";
                  repeat_rate = "60";
              };
          };
          keybindings = let
              modifier = config.wayland.windowManager.sway.config.modifier;
              in lib.mkOptionDefault {
                  "${modifier}+Return" = "exec ${pkgs.foot}/bin/foot";
                  "${modifier}+Shift+c" = "kill";
                  "${modifier}+Shift+r" = "reload";
                  "${modifier}+Shift+q" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
                  "${modifier}+p" = "exec ${pkgs.bemenu}/bin/bemenu-run";
                  "${modifier}+Tab" = "workspace back_and_forth";
                  "${modifier}+x" = "exec ${pkgs.cinnamon.nemo}/bin/nemo";
                  "${modifier}+y" = "exec ${pkgs.hyprpicker}/bin/hyprpicker | wl-copy";
                  "${modifier}+BackSpace" = "exec swaymsg input type:keyboard xkb_switch_layout next";
                  "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
                  "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
          };
          modifier = "Mod4";
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

  services = {
    mpris-proxy.enable = true;
    mako = {
      enable = true;
      anchor = "top-right";
      defaultTimeout = 5000;
      font = "${font}";
      layer = "top";
      groupBy = "app-name";
    };
  };

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${homeDirectory}/desk";
      documents = "${homeDirectory}/docs";
      download = "${homeDirectory}/down";
      music = "${homeDirectory}/music";
      pictures = "${homeDirectory}/pics";
      publicShare = "${homeDirectory}/share";
      templates = "${homeDirectory}/templates";
      videos = "${homeDirectory}/vids";
      extraConfig = {
          XDG_MISC_DIR = "${homeDirectory}/misc";
      };
    };

}

