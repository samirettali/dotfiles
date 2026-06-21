{pkgs, ...}: {
  imports = [
    ./wm
  ];

  services = {
    mpris-proxy.enable = true;
  };

  home.packages = with pkgs; [
    ledger-live-desktop
    lmstudio
  ];
}
