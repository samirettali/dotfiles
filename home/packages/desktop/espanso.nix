{...}: {
  services.espanso = {
    enable = true;
    matches = {
      base = {
        matches = [
          {
            trigger = ":wallet";
            replace = "0xc632b0c926291da28F8496d4F33CBE1f454E6F64";
          }
          {
            trigger = ":em";
            replace = "ettali.samir@gmail.com";
          }
          {
            trigger = ":wem";
            replace = "s.ettali@young.business";
          }
          {
            trigger = ":ts";
            replace = "{{unixtime}}";
          }
          {
            trigger = ":uuid";
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
        ];
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
