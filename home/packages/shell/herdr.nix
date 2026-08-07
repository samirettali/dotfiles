{
  config,
  nurPkgs,
  ...
}: {
  # Herdr's [theme.custom] only exposes palette-wide tokens, so restyling one
  # component drags every other user of that token along. The patch adds
  # per-component tokens for the sidebar spaces and the tab bar. It lives here
  # rather than in NUR so that package stays vanilla upstream.
  home.packages = [
    (nurPkgs.herdr.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./herdr-theme-tokens.patch];
    }))
  ];

  # TODO
  # xdg.configFile."herdr/config.toml" = {
  #   enable = builtins.elem nurPkgs.herdr config.home.packages;
  #   source = ../../dotfiles/herdr/config.toml;
  # };
}
