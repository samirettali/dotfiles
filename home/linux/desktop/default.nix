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
    brave
    zed-editor
  ];

  # TODO:
  # - use ungoogled-chromium
  # - disable smooth scroll
  programs.chromium = {
    enable = true;
    # package = pkgs.ungoogled-chromium;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock
      { id = "acmacodkjbdgmoleebolmdjonilkdbch"; } # rabby
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
      { id = "oboonakemofpalcgghocfoadofidjkkk"; } # keepassxc
    ];
  };
}
