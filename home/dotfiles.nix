{ ... }: {
  home.file = {
    ".ideavimrc".source = dotfiles/ideavimrc;
    ".config/nvim" = { source = dotfiles/nvim; recursive = true; };
    ".bin" = { source = dotfiles/scripts; recursive = true; };
    ".config/karabiner" = { source = dotfiles/karabiner; recursive = true; };
    ".Xdefaults".source = dotfiles/Xdefaults;
    ".config/zed/settings.json".source = dotfiles/zed.json;
  };
}
