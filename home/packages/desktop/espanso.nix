{config, ...}: let
  keys = ["evm" "svm" "hot" "alt" "em" "wem" "pri"];
  matches =
    builtins.map (name: {
      regex = ":(?i)${name}";
      replace = "{{${name}}}";
      vars = [
        {
          name = "${name}";
          type = "shell";
          params = {
            cmd = "cat ${config.sops.secrets."espanso_matches/${name}".path}";
          };
        }
      ];
    })
    keys;
in {
  services.espanso = {
    enable = false;
    matches = {
      base = {
        matches =
          [
            {
              regex = ":(?i)ts";
              replace = "{{unixtime}}";
            }
            {
              regex = ":(?i)uuid";
              replace = "{{output}}";
              vars = [
                {
                  name = "output";
                  type = "shell";
                  params = {
                    cmd = "uuidgen";
                  };
                }
              ];
            }
          ]
          ++ matches;
      };
      global_vars = {
        global_vars = [
          {
            name = "unixtime";
            type = "date";
            params = {format = "%s";};
          }
        ];
      };
    };
  };
}
