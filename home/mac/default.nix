{
  pkgs,
  nurPkgs,
  ...
}: {
  imports = [
    ./gpg.nix
    ./google-chrome.nix
    ./hammerspoon.nix
    ./sketchybar.nix
    ./desktoppr.nix
    ./rift.nix
  ];

  home.packages = with pkgs; [
    betterdisplay
    docker
    hidden-bar
    maccy
    pika
    nurPkgs.mole
    nurPkgs.sol
    nurPkgs.eqmac
    shottr
    the-unarchiver
  ];
}
