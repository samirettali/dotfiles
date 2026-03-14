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
    maccy
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.mole
    shottr
    the-unarchiver
  ];

  targets.darwin.copyApps.enableChecks = false; # TODO: upstream is broken

  programs = {
    gpg.enable = true;
  };
}
