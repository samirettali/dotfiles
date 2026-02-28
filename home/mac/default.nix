{
  pkgs,
  samirettali-nur,
  ...
}: {
  imports = [
    ./aerospace.nix
    ./hammerspoon.nix
    ./sketchybar.nix
  ];

  home.packages = [
    # docker
    samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system}.mole
  ];

  targets.darwin.copyApps.enableChecks = false; # TODO: upstream is broken

  programs = {
    gpg.enable = true;
  };
}
