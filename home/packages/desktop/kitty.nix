{
  lib,
  vars,
  ...
}: {
  programs.kitty = {
    enable = lib.mkDefault false;
    font = {
      name = vars.font.name;
      size = vars.font.size;
    };
    extraConfig = ''
      cursor_shape block
      map ctrl+shift+plus change_font_size all +0.5
      map ctrl+shift+minus change_font_size all -0.5
      confirm_os_window_close 0
      repaint_delay 2
      input_delay 0
      sync_to_monitor no
      disable_ligatures always
      wayland_enable_ime no
    '';
  };
}
