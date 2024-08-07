{ pkgs
, ...
}: {
  imports = [
    ./wm
    ./firefox.nix
    ./mpv.nix
  ];

  services = {
    mpris-proxy.enable = true;
  };

  home.packages = with pkgs; [
    ledger-live-desktop
    newsflash
    ungoogled-chromium
    brave
    zed-editor
  ];
}
