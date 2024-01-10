{ pkgs
, ...
}: {
  imports = [
    ./vscode.nix
    ./wezterm.nix
  ];

  home.packages = with pkgs; [
    keepassxc
    qbittorrent
    spotify
    discord
  ];
}
