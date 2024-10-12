{pkgs, ...}: {
  imports = [
    ./vscode.nix
    ./kitty.nix
    ./alacritty.nix
    ./espanso.nix
  ];

  home.packages = with pkgs; [
    discord
    keepassxc
    qbittorrent
    spotify
  ];
}
