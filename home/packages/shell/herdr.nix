{
  inputs,
  config,
  nurPkgs,
  lib,
  ...
}: {
  home.packages = [
    (import ./herdr-package.nix {inherit inputs nurPkgs;})
  ];

  xdg.configFile."herdr/config.toml" = {
    enable = lib.any (p: (p.pname or "") == "herdr") config.home.packages;
    source = ../../dotfiles/herdr/config.toml;
  };
}
