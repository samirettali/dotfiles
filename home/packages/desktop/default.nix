{pkgs, ...}: let
  keepassxcPkgs = import (builtins.fetchGit {
    name = "keepassxc-pkgs";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixpkgs-unstable";
    rev = "0bd7f95e4588643f2c2d403b38d8a2fe44b0fc73";
  }) {system = pkgs.system;};
in {
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
    spotify
  ];

  programs = {
    keepassxc = {
      package = keepassxcPkgs.keepassxc; # TODO: remove when upstream is fixed
      enable = true;
    };
  };
}
