{
  inputs,
  nurPkgs,
  ...
}: {
  # samirettali/herdr, branch `patched`: five commits on top of the released tag
  # adding per-component theme tokens, a `spacer` sidebar token, tab row
  # spacing, borderless outer panes and command restore. The NUR package stays
  # vanilla upstream and only its source is swapped, so `cargoDeps` still comes
  # from upstream — which is fine while the fork leaves `Cargo.lock` alone, and
  # fails loudly if it ever does not.
  home.packages = [
    (nurPkgs.herdr.overrideAttrs (_: {
      src = inputs.herdr-fork;
    }))
  ];

  # TODO
  # xdg.configFile."herdr/config.toml" = {
  #   enable = builtins.elem nurPkgs.herdr config.home.packages;
  #   source = ../../dotfiles/herdr/config.toml;
  # };
}
