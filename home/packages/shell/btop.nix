{lib, ...}: {
  programs.btop = {
    enable = lib.mkDefault true;
    settings = {
      color_theme = "TTY";
      vim_keys = true;
    };
  };
}
