{ pkgs
, inputs
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
      package = inputs.wezterm.packages.${pkgs.system}.default;
      extraConfig = builtins.readFile ../../dotfiles/wezterm.lua;
    };
  };
}
