{lib, ...}: {
  programs.bat = {
    enable = lib.mkDefault true;
    config = {
      theme = "base16";
      style = "numbers,changes,header";
      italic-text = "never";
    };
  };
}
