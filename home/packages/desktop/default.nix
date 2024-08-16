{pkgs, ...}: {
  imports = [
    ./vscode.nix
    ./kitty.nix
    ./alacritty.nix
  ];

  home.packages = with pkgs; [
    keepassxc
    qbittorrent
    spotify
    discord
  ];

  programs = {
    wezterm = {
      enable = false;
      extraConfig = builtins.readFile ../../dotfiles/wezterm.lua;
    };
  };
}
