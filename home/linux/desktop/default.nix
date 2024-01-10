{ ... }: {
  imports = [
    ./wm
    ./firefox.nix
    ./mpv.nix
  ];

  services = {
    mpris-proxy.enable = true;
  };
}
