{lib, ...}: {
  programs.bat = {
    enable = lib.mkDefault false;
    config = {
      theme = "base16";
      style = "numbers,changes,header";
      italic-text = "never";
    };
  };
}
