{ ... }: {
  imports = [
    ./wm
    ./firefox
    ./mpv.nix
  ];

  services = {
    mpris-proxy.enable = true;
  };
}
