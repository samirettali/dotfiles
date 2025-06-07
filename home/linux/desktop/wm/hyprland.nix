{
  config,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };
    xwayland.enable = true;
    settings = {
      ecosystem.no_update_news = true;
      general = {
        gaps_in = 4;
        gaps_out = 4;
        border_size = 1;
        "col.active_border" = "0xffbbbbbb";
        "col.inactive_border" = "0xff222222";
      };
      input = {
        kb_layout = "us,it";
        repeat_rate = 60;
        repeat_delay = 200;
        sensitivity = 1.0;
        touchpad.disable_while_typing = true;
      };
      dwindle = {
        split_width_multiplier = 1.35;
      };
      misc = {
        background_color = "0x141414";
        new_window_takes_over_fullscreen = 2;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };
      decoration = {
        rounding = 0;
        blur.enabled = false;
      };
      animations.enabled = false;
      exec-once = [
        "dbus-update-activation-environment --systemd --all"
        ''${lib.getExe' pkgs.wl-clipboard "wl-paste"} --watch cliphist store''
      ];
      binds = {
        workspace_back_and_forth = true;
        allow_workspace_cycles = true;
      };

      bind = let
        swaylock = lib.getExe config.programs.swaylock.package;
        terminal = config.home.sessionVariables.TERMINAL;
        fileExplorer = lib.getExe pkgs.nemo;
        bemenuRun = lib.getExe pkgs.bemenu;
        bemenu = lib.getExe pkgs.bemenu;
        cliphist = lib.getExe pkgs.cliphist;
        hyprctl = lib.getExe pkgs.hyprland;
        jq = lib.getExe pkgs.jq;
        wtype = lib.getExe pkgs.wtype;
        wlcopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
        hyprpicker = lib.getExe pkgs.hyprpicker;

        workspaces = map (n: toString n) (lib.range 1 9);
        directions = rec {
          left = "l";
          right = "r";
          up = "u";
          down = "d";
          h = left;
          l = right;
          k = up;
          j = down;
        };
      in
        [
          "SUPER,TAB,workspace,previous"
          "SUPERSHIFT,c,killactive"
          "SUPERSHIFT,e,exit"
          "SUPER,f,fullscreen,1"
          "SUPERSHIFT,SPACE,togglefloating"
          "SUPER,SPACE,exec,${bemenuRun}"
          "SUPER,RETURN,exec,${terminal}"
          "SUPER,x,exec,${fileExplorer}"
          "SUPER,y,exec,${hyprpicker}"

          ",Print,exec,screenshot"

          "SUPER,c,exec,${wtype} -P XF86Copy"
          "SUPER,x,exec,${wtype} -P XF86Cut"
          "SUPER,v,exec,${wtype} -P XF86Paste"
          "SUPERSHIFT,v,exec,${cliphist} list | ${bemenu} | ${cliphist} decode | ${wlcopy} && ${wtype} -P XF86Paste"
          "SUPER,BACKSPACE,exec,for keyboard in $(${hyprctl} devices -j | ${jq} -r '. | .keyboards | .[] | .name'); do ${hyprctl} switchxkblayout $keyboard next > /dev/null; done"
        ]
        ++ (lib.optionals config.programs.swaylock.enable [
          "SUPERSHIFT,l,exec,${swaylock} -S --grace 2"
        ])
        ++ (lib.optionals config.programs.password-store.enable [
          "SUPER,p,exec,passbemenu"
        ])
        ++ (map
          (
            n: "SUPER,${n},workspace,${n}"
          )
          workspaces)
        ++ (map
          (
            n: "SUPERSHIFT,${n},movetoworkspacesilent,${n}"
          )
          workspaces)
        ++ (lib.mapAttrsToList
          (
            key: direction: "SUPER,${key},movefocus,${direction}"
          )
          directions)
        ++ (lib.mapAttrsToList
          (
            key: direction: "SUPERSHIFT,${key},swapwindow,${direction}"
          )
          directions)
        ++ (lib.mapAttrsToList
          (
            key: direction: "SUPERCONTROL,${key},movewindoworgroup,${direction}"
          )
          directions)
        ++ (lib.mapAttrsToList
          (
            key: direction: "SUPERALT,${key},focusmonitor,${direction}"
          )
          directions)
        ++ (lib.mapAttrsToList
          (
            key: direction: "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}"
          )
          directions);
      binde = let
        wpctl = lib.getExe lib.pkgs.wireplumber "wpctl";
      in [
        ",XF86AudioRaiseVolume,exec,${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,exec,${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
      bindm = [
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow"
      ];
    };
    # windowrule=float,^(pavucontrol)$
    # windowrule=float,title:^(Picture-in-Picture)$
    # windowrule=workspace 8,^(Spotify)$
    extraConfig = ''
      windowrulev2=suppressevent maximize fullscreen,class:^(mpv)$

      windowrule=float,title:^(_crx_acmacodkjbdgmoleebolmdjonilkdbch)$
      windowrulev2=stayfocused,title:^(_crx_acmacodkjbdgmoleebolmdjonilkdbch)$

      # Smart borders
      workspace = w[tv1], gapsout:0, gapsin:0
      workspace = f[1], gapsout:0, gapsin:0
      windowrule = bordersize 0, floating:0, onworkspace:w[tv1]
      windowrule = rounding 0, floating:0, onworkspace:w[tv1]
      windowrule = bordersize 0, floating:0, onworkspace:f[1]
      windowrule = rounding 0, floating:0, onworkspace:f[1]
    '';
  };
}
