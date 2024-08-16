{ lib, pkgs, ... }: {
  home.file = lib.mkMerge [{
    ".ideavimrc".source = dotfiles/ideavimrc;
    ".config/nvim" = { source = dotfiles/nvim; recursive = true; };
    ".config/karabiner" = lib.mkIf pkgs.stdenv.isDarwin { source = dotfiles/karabiner; recursive = true; };
    ".Xdefaults".source = dotfiles/Xdefaults;
    ".config/zed/settings.json".source = dotfiles/zed.json;
    "revive.toml".source = dotfiles/revive.toml;

    ".bin/extract".source = dotfiles/scripts/extract.sh;
    ".bin/glc".source = dotfiles/scripts/glc.sh;
    ".bin/gr".source = dotfiles/scripts/gr.sh;
    ".bin/tad".source = dotfiles/scripts/tad.sh;
  }
  (lib.mkIf pkgs.stdenv.isLinux {
    ".bin/passbemenu".source = dotfiles/scripts/passbemenu.sh;
    ".bin/scratchpad".source = dotfiles/scripts/scratchpad.sh;
    ".bin/screenshot".source = dotfiles/scripts/screenshot.sh;
  })
  (lib.mkIf pkgs.stdenv.isDarwin {
    ".bin/display".source = dotfiles/scripts/display.sh;
  })];
}
