{ pkgs
, ...
}: {
  imports = [
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    keepassxc
    qbittorrent
    spotify
    discord
  ];
}
