{ ... }: {
  home.file = {
    ".config/wezterm/wezterm.lua".source = dotfiles/wezterm.lua;
    ".Xdefaults".source = dotfiles/Xdefaults;
    ".ideavimrc".source = dotfiles/ideavimrc;
    ".config/bc".source = dotfiles/bc;
    ".config/nvim" = { source = dotfiles/nvim; recursive = true; };
    ".bin" = { source = dotfiles/scripts; recursive = true; };
  };
}
