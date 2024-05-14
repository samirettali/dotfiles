{ pkgs
, ...
}: {
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
      enable = true;
      extraConfig = builtins.readFile ../../dotfiles/wezterm.lua;
    };
  };
}
