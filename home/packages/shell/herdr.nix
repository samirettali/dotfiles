{
  config,
  nurPkgs,
  ...
}: {
  xdg.configFile."herdr/config.toml" = {
    enable = builtins.elem nurPkgs.herdr config.home.packages;
    source = ../../dotfiles/herdr/config.toml;
  };
}
