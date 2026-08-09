{
  inputs,
  nurPkgs,
}:
# samirettali/herdr, branch `patched`: commits on top of the released tag adding
# per-component theme tokens, a `spacer` sidebar token, tab row spacing,
# borderless outer panes and command restore. The NUR package stays vanilla
# upstream and only its source is swapped, so `cargoDeps` still comes from
# upstream — fine while the fork leaves `Cargo.lock` alone, and it fails loudly
# if it ever does not.
#
# Defined apart from `herdr.nix` so anything that needs the binary by path — the
# sketchybar watcher — gets this exact build instead of guessing a profile path.
nurPkgs.herdr.overrideAttrs (_: {
  src = inputs.herdr-fork;
})
