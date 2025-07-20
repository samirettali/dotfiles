{lib, ...}: {
  programs.neovim = {
    enable = lib.mkDefault true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
