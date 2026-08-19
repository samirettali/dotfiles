{
  pkgs,
  lib,
  nurPkgs,
  ...
}: {
  imports = [
    ./colima.nix
    ./gpg.nix
    ./hammerspoon.nix
    ./sketchybar.nix
    ./sottomano.nix
    ./desktoppr.nix
    ./aerospace.nix
    # ./rift.nix # temporarily disabled in favor of aerospace
  ];

  home.packages = with pkgs; [
    betterdisplay
    hidden-bar
    maccy
    pika
    nurPkgs.mole
    nurPkgs.sol
    nurPkgs.eqmac
    nurPkgs.sottomano
    shottr
    the-unarchiver
    slack
    mongodb-compass
  ];

  # LaunchServices caches the store path behind a bundle id, and the old build is
  # still there — so `open -a`, Spotlight and Hammerspoon launch the previous one.
  home.activation.registerLinkedApps = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -d "$HOME/Applications/Home Manager Apps" ]; then
      run /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -f "$HOME/Applications/Home Manager Apps"/*.app
    fi
  '';
}
