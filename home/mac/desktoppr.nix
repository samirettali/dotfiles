{pkgs, ...}: let
  wallpaper = pkgs.runCommand "wallpaper.png" {} ''
    ${pkgs.imagemagick}/bin/magick -size 1x1 canvas:#021623 "$out"
  '';
in {
  programs.desktoppr = {
    enable = true;
    settings = {
      picture = "${wallpaper}";
      scale = "fill";
      setOnlyOnce = false;
    };
  };
}
