{ pkgs
, ...
}: {
  services.kanshi = {
    enable = true;
    profiles = {
      docked = {
        outputs = [
          {
            criteria = "DP-1";
            status = "enable";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
        exec = [
          "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-1"
        ];
      };
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 2.0;
          }
        ];
      };
    };
  };
}
