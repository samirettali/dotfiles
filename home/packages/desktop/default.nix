{pkgs, ...}: {
  imports = [
    ./vscode.nix
    ./kitty.nix
    ./wezterm.nix
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
