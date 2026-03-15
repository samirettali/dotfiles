{
  pkgs,
  samirettali-nur,
  ...
}: {
  imports = [
    ./hammerspoon.nix
    ./sketchybar.nix
  ];

  home.packages = with pkgs; [
    betterdisplay
    choose-gui
    docker
    hidden-bar
    maccy
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.mole
    shottr
    the-unarchiver
  ];

  programs = {
    gpg.enable = true;
  };
}
