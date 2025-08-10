{
  pkgs,
  config,
  ...
}: let
  toYAML = obj: let
    jsonStr = builtins.toJSON obj;
  in
    builtins.readFile (pkgs.runCommand "json-to-yaml" {
        buildInputs = [pkgs.yj];
      } ''
        echo '${jsonStr}' | yj -jy > $out
      '');
in {
  home.packages = with pkgs; [
    posting
  ];

  xdg.configFile."posting.config.yaml" = {
    force = true;
    enable = builtins.elem pkgs.posting config.home.packages;
    text = toYAML {
      spacing = "compact";
    };
  };
}
