{
  inputs,
  pkgs,
}:
# samirettali/herdr, branch `patched`: commits on top of upstream master adding
# pane border and tab bar colours, an optional prefix hint bar and pane keys
# that listed programs keep for themselves. Built from the fork's own
# `nix/package.nix`, which reads `Cargo.lock` from the tree, so nothing here
# depends on the vanilla NUR package or its hashes.
#
# Defined apart from `herdr.nix` so anything that needs the binary by path — the
# sketchybar watcher — gets this exact build instead of guessing a profile path.
pkgs.callPackage "${inputs.herdr-fork}/nix/package.nix" {}
