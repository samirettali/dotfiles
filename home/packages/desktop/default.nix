{pkgs, ...}: {
  imports = [
    ./vscode.nix
    ./kitty.nix
    ./alacritty.nix
  ];

  home.packages = with pkgs; [
    discord
    keepassxc
    qbittorrent
    spotify
    # zed-editor
  ];
}
