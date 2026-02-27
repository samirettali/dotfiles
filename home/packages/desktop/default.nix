{pkgs, ...}: {
  imports = [
    ./alacritty.nix
    ./cursor.nix
    ./discord.nix
    ./espanso.nix
    ./firefox
    ./ghostty.nix
    ./keepassxc.nix
    ./kitty.nix
    ./mpv.nix
    ./obsidian.nix
    ./vscode.nix
    ./wezterm.nix
    ./zed.nix
  ];

  home.packages = with pkgs; [
    spotify
  ];
}
