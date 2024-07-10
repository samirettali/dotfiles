{ ... }: {
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      {
        profile = {
          name = "docked";
          outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "DP-1";
              status = "enable";
              scale = 1.0;
            }
          ];
          exec = [
            "hyprctl dispatch moveworkspacetomonitor 1 DP-1"
          ];
        };
      }
    ];
  };
}
