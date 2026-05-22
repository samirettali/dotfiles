{pkgs, ...}: let
  blackWallpaper = pkgs.runCommand "black-wallpaper.png" {} ''
    ${pkgs.imagemagick}/bin/magick -size 1x1 xc:black "$out"
  '';
in {
  programs.desktoppr = {
    enable = true;
    settings = {
      picture = "${blackWallpaper}";
      scale = "fill";
      setOnlyOnce = false;
    };
  };
}
