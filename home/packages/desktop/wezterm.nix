{lib, ...}: {
  programs.wezterm = {
    enable = lib.mkDefault false;
    extraConfig = builtins.readFile ../../../home/dotfiles/wezterm.lua;
  };
}
