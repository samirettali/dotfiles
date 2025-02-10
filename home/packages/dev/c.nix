{pkgs, ...}: {
  home.packages = with pkgs; [
    clang-tools
    cmake
    cppcheck
    cpplint
    gcc
    gnumake
  ];
}
