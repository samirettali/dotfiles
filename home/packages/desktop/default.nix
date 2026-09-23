{pkgs, ...}: {
  imports = [
    ./discord.nix
    ./ghostty.nix
    ./helium.nix
    ./keepassxc.nix
    ./mpv.nix
    ./obsidian.nix
    ./zed.nix
  ];

  home.packages = with pkgs; [
    spotify
    neohtop
  ];
}
