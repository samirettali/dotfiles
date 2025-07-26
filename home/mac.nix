{pkgs, ...}: {
  imports = [
    ./hammerspoon.nix
  ];

  home.packages = with pkgs; [
    asitop
    nur.repos.natsukium.hammerspoon
    # docker
  ];

  programs = {
    gpg.enable = true;
  };

  home.file = {
    ".config/sketchybar" = {
      source = dotfiles/sketchybar;
      recursive = true;
    };
  };
}
