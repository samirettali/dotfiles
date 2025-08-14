{pkgs, ...}: {
  imports = [
    ./aerospace.nix
    ./hammerspoon.nix
    ./sketchybar.nix
  ];

  home.packages = with pkgs; [
    nur.repos.natsukium.hammerspoon
    # docker
  ];

  programs = {
    gpg.enable = true;
  };
}
