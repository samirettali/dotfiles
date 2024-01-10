{ ... }: {
  imports = [
    ./wm
    ./firefox
    ./mpv.nix
  ];

  home.packages = with pkgs;[
    ledger-live-desktop
    discord
  ];

  services = {
    mpris-proxy.enable = true;
  };
}
