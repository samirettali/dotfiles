{nurPkgs, ...}: {
  home.packages = [nurPkgs.hunk];

  xdg.configFile."hunk/config.toml".source = ../../dotfiles/hunk/config.toml;
}
