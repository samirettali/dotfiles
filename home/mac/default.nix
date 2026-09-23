{
  pkgs,
  lib,
  nurPkgs,
  ...
}: {
  imports = [
    ./colima.nix
    ./sketchybar.nix
    ./sottomano.nix
    ./desktoppr.nix
    ./aerospace.nix
  ];

  home.packages = with pkgs; [
    betterdisplay
    mongodb-compass
    nurPkgs.eqmac
    nurPkgs.mole
    nurPkgs.sottomano
    nurPkgs.sottovoce
    nurPkgs.t3code
    shottr
    slack
    telegram-desktop
    the-unarchiver
  ];

  # LaunchServices caches the store path behind a bundle id, and the old build is
  # still there — so `open -a`, Spotlight and sottomano launch the previous one,
  # without the TCC grants the Home Manager Apps copy holds. Forget every store
  # copy it knows, then register the stable ones. Best effort: a failure here
  # must not stop the switch.
  home.activation.registerLinkedApps = lib.hm.dag.entryAfter ["writeBoundary"] ''
    lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
    "$lsregister" -dump 2>/dev/null \
      | sed -n 's#^path: *\(/nix/store/[^ ]*\.app\) (.*#\1#p' \
      | sort -u \
      | while read -r app; do
        if [ -e "$app" ]; then
          run "$lsregister" -u "$app" || true
        fi
      done || true
    if [ -d "$HOME/Applications/Home Manager Apps" ]; then
      run "$lsregister" -f "$HOME/Applications/Home Manager Apps"/*.app
    fi
  '';
}
