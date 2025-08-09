{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    posting
  ];

  xdg.configFile."posting.config.yaml" = {
    force = true;
    enable = builtins.elem pkgs.posting config.home.packages;
    text = lib.generators.toYAML {
      spacing = "compact";
    };
  };
}
