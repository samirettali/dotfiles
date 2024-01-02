{ pkgs
, ...
}: {
  services = {
    espanso = {
      enable = true;
      package = pkgs.espanso-wayland;
      configs = {
        default = {
          show_notifications = false;
        };
        vscode = {
          filter_title = "Visual Studio Code$";
          backend = "Clipboard";
        };
      };
      matches = {
        base = {
          matches = [
            {
              trigger = ":gm";
              replace = "ettali.samir@gmail.com";
            }
            {
              regex = ":cf";
              replace = "TTLSMR95E21F335Z";
            }
            {
              regex = ":ts";
              replace = "{{ts}}";
            }
            {
              regex = ":uuid";
              replace = "{{uuid}}";
            }
          ];
        };
        global_vars = {
          global_vars = [
            {
              name = "now";
              type = "date";
              params = { format = "%d/%m/%Y"; };
            }
            {
              name = "ts";
              type = "date";
              params = { format = "%s"; };
            }
            {
              name = "uuid";
              type = "shell";
              params = {
                cmd = "uuidgen";
              };
            }
          ];
        };
      };
    };
  };
}
