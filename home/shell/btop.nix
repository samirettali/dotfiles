{lib, ...}: {
  programs.btop = {
    enable = lib.mkDefault false;
    settings = {
      color_theme = "TTY";
      vim_keys = true;
    };
  };
}
