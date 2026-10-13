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
#
# On Linux it links with lld: with binutils 2.46, ld.bfd rejects the debug
# relocations in the compiler_rt object Zig puts in libghostty-vt.a.
let
  herdr = pkgs.callPackage "${inputs.herdr-fork}/nix/package.nix" {};
in
  if pkgs.stdenv.hostPlatform.isLinux
  then
    herdr.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.lld];
      env = old.env // {RUSTFLAGS = "-C link-arg=-fuse-ld=lld";};
    })
  else herdr
