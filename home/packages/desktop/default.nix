{pkgs, lib, ...}: {
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

  programs = {
    wezterm = {
      enable = lib.mkDefault false;
      extraConfig = builtins.readFile ../../dotfiles/wezterm.lua;
    };
  };
}
