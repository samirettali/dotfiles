{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals (config.features.c == "minimal" || config.features.c == "full") [
      gcc
    ]
    ++ lib.optionals (config.features.c == "full") [
      clang-tools
      cmake
      cppcheck
      cpplint
      gnumake
    ];
}
