{
  inputs,
  nurPkgs,
  ...
}: {
  home.packages = [
    (import ./herdr-package.nix {inherit inputs nurPkgs;})
  ];

  # TODO
  # xdg.configFile."herdr/config.toml" = {
  #   enable = builtins.elem nurPkgs.herdr config.home.packages;
  #   source = ../../dotfiles/herdr/config.toml;
  # };
}
