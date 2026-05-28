{
  pkgs,
  samirettali-nur,
  ...
}: {
  imports = [
    ./hammerspoon.nix
    ./sketchybar.nix
    ./desktoppr.nix
  ];

  home.packages = with pkgs; [
    betterdisplay
    docker
    hidden-bar
    maccy
    pika
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.mole
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.sol
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.eqmac
    shottr
    the-unarchiver
  ];

  programs = {
    gpg.enable = true;
  };
}
