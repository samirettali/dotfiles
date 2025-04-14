{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    nil
    nixd
  ];
}
