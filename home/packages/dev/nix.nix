{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    deadnix
    nixd
    statix
  ];
}
