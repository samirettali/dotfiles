{
  pkgs,
  config,
  ...
}: let
  yaml = pkgs.formats.yaml {};

  configFile = yaml.generate "posting.config.yaml" {
    spacing = "compact";
  };
in {
  home.packages = with pkgs; [
    # posting
  ];

  xdg.configFile."posting.config.yaml" = {
    force = true;
    enable = builtins.elem pkgs.posting config.home.packages;
    source = configFile;
  };
}
