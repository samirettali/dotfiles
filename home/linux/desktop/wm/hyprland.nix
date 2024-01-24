{ config
, pkgs
, lib
, ...
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
      general = {
        gaps_in = 1;
        gaps_out = 1;
        border_size = 1;
        cursor_inactive_timeout = 4;
        "col.active_border" = "0xffbbbbbb";
        "col.inactive_border" = "0xff222222";
      };
      input = {
        kb_layout = "us,it";
        touchpad.disable_while_typing = true;
        repeat_rate = 60;
        repeat_delay = 200;
      };
      dwindle = {
        no_gaps_when_only = true;
        split_width_multiplier = 1.35;
      };
      misc = {
        new_window_takes_over_fullscreen = 2;
      };
      decoration = {
        rounding = 0;
        blur.enabled = false;
        drop_shadow = false;
      };
      animations.enabled = false;
      exec = [
        "${pkgs.swaybg}/bin/swaybg -i /home/samir/pics/walls/bg.png --mode tile"
      ];
      exec-once = [
        "${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store"
      ];

      bind =
        let
          swaylock = "${config.programs.swaylock.package}/bin/swaylock";
          grimblast = "${pkgs.grimblast}/bin/grimblast";
          pactl = "${pkgs.pulseaudio}/bin/pactl";
          terminal = config.home.sessionVariables.TERMINAL;
          fileExplorer = "${pkgs.cinnamon.nemo}/bin/nemo";
          bemenuRun = "${pkgs.bemenu}/bin/bemenu-run";
          bemenu = "${pkgs.bemenu}/bin/bemenu";
          cliphist = "${pkgs.cliphist}/bin/cliphist";
          hyprctl = "${pkgs.hyprland}/bin/hyprctl";

          wtype = "${pkgs.wtype}/bin/wtype";
          wlcopy = "${pkgs.wl-clipboard}/bin/wl-copy";

          hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";

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
          "SUPERSHIFT,q,killactive"
          "SUPERSHIFT,e,exit"
          "SUPER,f,fullscreen,1"

          "SUPER,RETURN,exec,${terminal}"
          "SUPER,d,exec,${bemenuRun}"
          "SUPER,x,exec,${fileExplorer}"
          "SUPER,y,exec,${hyprpicker}"

          ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
          ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
          ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
          "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
          ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"

          ",Print,exec,screenshot"

          "SUPER,c,exec,${wtype} -P XF86Copy"
          "SUPER,x,exec,${wtype} -P XF86Cut"
          "SUPER,v,exec,${wtype} -P XF86Paste"
          "SUPERSHIFT,v,exec,${cliphist} list | ${bemenu} | ${cliphist} decode | ${wlcopy} && ${wtype} -P XF86Paste"
          "SUPER,q,exec,${hyprctl} switchxkblayout at-translated-set-2-keyboard next"
          "SUPER,w,exec,${hyprctl} activewindow | ${wlcopy}"
        ] ++
        (lib.optionals config.programs.swaylock.enable [
          "SUPERSHIFT,l,exec,${swaylock} -S --grace 2"
        ]) ++
        (lib.optionals config.programs.password-store.enable [
          "SUPER,p,exec,passbemenu"
        ]) ++
        (map
          (n:
            "SUPER,${n},workspace,${n}"
          )
          workspaces) ++
        (map
          (n:
            "SUPERSHIFT,${n},movetoworkspacesilent,${n}"
          )
          workspaces) ++
        (lib.mapAttrsToList
          (key: direction:
            "SUPER,${key},movefocus,${direction}"
          )
          directions) ++
        (lib.mapAttrsToList
          (key: direction:
            "SUPERSHIFT,${key},swapwindow,${direction}"
          )
          directions) ++
        (lib.mapAttrsToList
          (key: direction:
            "SUPERCONTROL,${key},movewindoworgroup,${direction}"
          )
          directions) ++
        (lib.mapAttrsToList
          (key: direction:
            "SUPERALT,${key},focusmonitor,${direction}"
          )
          directions) ++
        (lib.mapAttrsToList
          (key: direction:
            "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}"
          )
          directions);
      bindm = [
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow"
      ];
    };
    extraConfig = ''
      windowrule=float,^(nemo)$
      windowrule=float,^(pavucontrol)$
      windowrule=nomaximizerequest,^(mpv)$
    '';
  };
}
