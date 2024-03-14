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
      text_composition_strategy legacy
      cursor_shape block
    '';
  };
}
