{lib, ...}: {
  programs.lazydocker = {
    enable = lib.mkDefault true;
    settings = {
      gui = {
        showBottomLine = false;
        returnImmediately = true;
      };
    };
  };
}
