{ ... }: {
  imports = [
    ./wm
    ./firefox
    ./mpv.nix
  ];

  home.packages = with pkgs;[
    ledger-live-desktop
  ];

  services = {
    mpris-proxy.enable = true;
  };
}
