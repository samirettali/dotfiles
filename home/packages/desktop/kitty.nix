{ lib
, pkgs
, ...
}: {
  programs.kitty = {
    enable = false;
    font = {
      # name = "JetBrainsMono Nerd Font";
      name = "Berkeley Mono";
      size = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin 14)
        (lib.mkIf pkgs.stdenv.isLinux 10)
      ];
    };
    extraConfig = ''
      cursor_shape block
      map ctrl+shift+plus change_font_size all +0.5
      map ctrl+shift+minus change_font_size all -0.5
      confirm_os_window_close 0
      input_delay 0
      disable_ligatures always
    '';
  };
}
