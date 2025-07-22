{pkgs, ...}: let
  copy = pkgs.callPackage ./copy.nix {};
in {
  home.packages = [
    copy
    (pkgs.callPackage ./nhash.nix {
      inherit copy;
    })
  ];
}
