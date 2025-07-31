{pkgs, ...}: {
  imports = [
    ./aerospace.nix
    ./hammerspoon.nix
    ./sketchybar.nix
  ];

  home.packages = with pkgs; [
    asitop
    nur.repos.natsukium.hammerspoon
    # docker
  ];

  programs = {
    gpg.enable = true;
  };
}
