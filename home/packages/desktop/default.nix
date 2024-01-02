{ pkgs
, ...
}: {
  imports = [
    ./vscode.nix
    ./espanso.nix
    ./wezterm.nix
  ];

  home.packages = with pkgs; [
    keepassxc
    qbittorrent
    spotify
  ];
}
