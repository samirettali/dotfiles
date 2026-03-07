{pkgs, ...}: {
  imports = [
    ./discord.nix
    ./firefox
    ./ghostty.nix
    ./keepassxc.nix
    ./mpv.nix
    ./obsidian.nix
    ./vscode.nix
    ./zed.nix
  ];

  home.packages = with pkgs; [
    spotify
    # neohtop
  ];
}
