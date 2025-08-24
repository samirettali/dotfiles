{pkgs, ...}: {
  imports = [
    ./aerospace.nix
    ./hammerspoon.nix
    ./sketchybar.nix
  ];

  home.packages = with pkgs; [
    # docker
  ];

  programs = {
    gpg.enable = true;
  };
}
