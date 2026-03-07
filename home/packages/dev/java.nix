{
  lib,
  pkgs,
  features,
  ...
}: {
  programs = {
    java.enable = features.java;
  };

  home.packages = with pkgs;
    lib.optionals features.java [
      jdt-language-server
    ];
}
