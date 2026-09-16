{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    (import ./herdr-package.nix {inherit inputs pkgs;})
  ];

  xdg.configFile."herdr/config.toml" = {
    enable = lib.any (p: (p.pname or "") == "herdr") config.home.packages;
    source = ../../dotfiles/herdr/config.toml;
  };
}
