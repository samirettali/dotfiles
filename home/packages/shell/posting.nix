{lib, ...}: {
  programs.posting = {
    enable = lib.mkDefault false;
    settings.spacing = "compact";
  };
}
