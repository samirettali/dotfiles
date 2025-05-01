{pkgs, ...}: {
  imports = [
    ./alacritty.nix
    ./espanso.nix
    ./firefox.nix
    ./kitty.nix
    ./mpv.nix
    ./vscode.nix
    ./wezterm.nix
    ./zed.nix
  ];

  home.packages = with pkgs; [
    discord
    keepassxc
    spotify
    # code-cursor
    # obsidian
  ];
}
