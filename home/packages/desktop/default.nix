{pkgs, ...}: {
  imports = [
    ./vscode.nix
    ./kitty.nix
    ./wezterm.nix
    ./alacritty.nix
    ./espanso.nix
    ./mpv.nix
  ];

  home.packages = with pkgs; [
    discord
    keepassxc
    qbittorrent
    spotify
  ];
}
