{
  lib,
  pkgs,
  config,
  ...
}: {
  home.file = lib.mkMerge [
    {
      ".ideavimrc".source = dotfiles/ideavimrc;
      ".config/nvim" = {
        source = dotfiles/nvim;
        recursive = true;
      };
      ".config/karabiner" = lib.mkIf pkgs.stdenv.isDarwin {
        source = dotfiles/karabiner;
        recursive = true;
      };
      ".Xdefaults".source = dotfiles/Xdefaults;
      "revive.toml".source = dotfiles/revive.toml;
      ".config/ghostty/config".source = dotfiles/ghostty;

      ".bin/extract".source = dotfiles/scripts/extract.sh;
      ".bin/glc".source = dotfiles/scripts/glc.sh;
      ".bin/tad".source = dotfiles/scripts/tad.sh;
      ".bin/ticker".source = dotfiles/scripts/ticker.sh;
      ".config/git-sync/config.yaml".text = let
        templ = builtins.readFile dotfiles/git-sync.yaml;
      in
        builtins.replaceStrings
        ["{{HOME}}"]
        ["${config.home.homeDirectory}"]
        templ;
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      ".bin/passbemenu".source = dotfiles/scripts/passbemenu.sh;
      ".bin/scratchpad".source = dotfiles/scripts/scratchpad.sh;
      ".bin/screenshot".source = dotfiles/scripts/screenshot.sh;
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      ".bin/display".source = dotfiles/scripts/display.sh;
      ".config/sketchybar" = {
        source = dotfiles/sketchybar;
        recursive = true;
      };
    })
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.bin"
  ];
}
