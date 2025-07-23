{lib, ...}: {
  programs = {
    java.enable = lib.mkDefault false;
  };
}
