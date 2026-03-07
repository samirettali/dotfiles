{
  pkgs,
  features,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals features.c [
      clang-tools
      cmake
      cppcheck
      cpplint
      gcc
      gnumake
    ];
}
