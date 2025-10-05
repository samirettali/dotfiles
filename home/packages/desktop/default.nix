{pkgs, ...}: {
  imports = [
    ./alacritty.nix
    ./espanso.nix
    ./firefox
    ./cursor.nix
    ./ghostty.nix
    ./keepassxc.nix
    ./kitty.nix
    ./mpv.nix
    ./vscode.nix
    ./wezterm.nix
    ./zed.nix
  ];

  home.packages = with pkgs; [
    discord
    spotify
  ];
}
