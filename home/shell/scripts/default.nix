{pkgs, ...}: let
  copy = pkgs.callPackage ./copy.nix {};
in {
  home.packages = [
    copy
    (pkgs.callPackage ./nh.nix {
      inherit copy;
    })
  ];
}
