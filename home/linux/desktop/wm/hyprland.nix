{ config, pkgs, lib, ... }: {

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };
    settings = {
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 1;
        cursor_inactive_timeout = 4;
        "col.active_border" = "0xffbdbdbd";
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
        drop_shadow = true;
        # shadow_range = 3;
        # shadow_offset = "3 3";
        # "col.shadow" = "0x44000000";
        # "col.shadow_inactive" = "0x66000000";
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

          # initialize workspaces for a range from 1 to 6 of string integers
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
          "SUPER,RETURN,exec,${terminal}"
          "SUPER,d,exec,bemenu-run"
          "SUPER,TAB,workspace,previous"
          "SUPERSHIFT,q,killactive"
          "SUPERSHIFT,e,exit"
          "SUPER,f,fullscreen,1"
          "SUPER,x,exec,${fileExplorer}"

          ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
          ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
          ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
          "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
          ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"

          ",Print,exec,${grimblast} --notify --freeze copy output"
          "SHIFT,Print,exec,${grimblast} --notify --freeze copy active"
          "CONTROL,Print,exec,${grimblast} --notify --freeze copy screen"
          "SUPER,Print,exec,${grimblast} --notify --freeze copy area"
          "ALT,Print,exec,${grimblast} --notify --freeze copy area"
          "SUPERSHIFT,v,exec,cliphist list | bemenu | cliphist decode | wl-copy"
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
