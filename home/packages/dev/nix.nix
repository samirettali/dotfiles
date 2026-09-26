{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    deadnix
    nixd
    statix
  ];

  dotfiles.neovim.lspServers = ["nixd"];
}
