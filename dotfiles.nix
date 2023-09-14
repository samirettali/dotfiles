{ ... }: {
  home.file = {
    ".config/wezterm/wezterm.lua".source = dotfiles/wezterm.lua;
    ".Xdefaults".source = dotfiles/Xdefaults;
    ".ackrc".source = dotfiles/ackrc;
    ".config/alacritty/alacritty.yml".source = dotfiles/alacritty.yml;
    ".ideavimrc".source = dotfiles/ideavimrc;
    ".config/foot/foot.ini".source = dotfiles/foot.ini;
    ".ripgreprc".source = dotfiles/ripgreprc;
    ".config/kanshi/config".source = dotfiles/kanshi_config;
    ".config/bc".source = dotfiles/bc;
    ".config/mpv" = { source = dotfiles/mpv; recursive = true; };
    ".config/nvim" = { source = dotfiles/nvim; recursive = true; };
    ".bin" = { source = dotfiles/scripts; recursive = true; };
  };
}
