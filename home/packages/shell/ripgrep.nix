{lib, ...}: {
  programs.ripgrep = {
    enable = lib.mkDefault true;
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--glob=!node_modules/*"
      "--glob=!.git/*"
      "--glob=!*.aof"
      "--hidden"
      "--smart-case"
    ];
  };
}
