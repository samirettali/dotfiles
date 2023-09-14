{ ... }: {
  home.file = {
    ".config/wezterm/wezterm.lua".source = dotfiles/wezterm.lua;
    ".Xdefaults".source = dotfiles/Xdefaults;
    ".config/alacritty/alacritty.yml".source = dotfiles/alacritty.yml;
    ".ideavimrc".source = dotfiles/ideavimrc;
    ".config/bc".source = dotfiles/bc;
    ".config/mpv" = { source = dotfiles/mpv; recursive = true; };
    ".config/nvim" = { source = dotfiles/nvim; recursive = true; };
    ".bin" = { source = dotfiles/scripts; recursive = true; };
  };
}
