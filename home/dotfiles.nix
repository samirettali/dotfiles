{...}: {
  home.file = {
    ".ideavimrc".source = ./dotfiles/ideavimrc;
    ".Xdefaults".source = ./dotfiles/Xdefaults;
    "revive.toml".source = ./dotfiles/revive.toml;

    ".config/nvim" = {
      source = ./dotfiles/nvim;
      recursive = true;
    };
  };
}
