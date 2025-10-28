{pkgs, ...}: {
  imports = [
    ./aerospace.nix
    ./hammerspoon.nix
    ./sketchybar.nix
  ];

  home.packages = with pkgs; [
    # docker
  ];

  targets.darwin.copyApps.enableChecks = false; # TODO: upstream is broken

  programs = {
    gpg.enable = true;
  };
}
