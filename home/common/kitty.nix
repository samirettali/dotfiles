{ lib
, pkgs
, ...
}: {
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin 14)
        (lib.mkIf pkgs.stdenv.isLinux 10)
      ];
    };
    extraConfig = ''
      text_composition_strategy 1.7 0
      cursor_shape block
      map ctrl+shift+plus change_font_size all +0.5
      map ctrl+shift+minus change_font_size all -0.5
    '';
  };
}
