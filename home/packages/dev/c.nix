{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.features.c [
      clang-tools
      cmake
      cppcheck
      cpplint
      gcc
      gnumake
    ];
}
