{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./c.nix
    ./go.nix
    ./js.nix
    ./lua.nix
    ./nix.nix
    ./python.nix
    ./rust.nix
    ./shell.nix
    ./web3.nix
    ./zig.nix
  ];

  home.packages = with pkgs; [
    ast-grep
    devbox
    devenv
    jdt-language-server
    libiconv
    stdenv
    tree-sitter
    vscode-langservers-extracted
    yamlfmt
    zizmor
  ];

  home.sessionVariables.LIBRARY_PATH = ''${lib.makeLibraryPath [pkgs.libiconv]}''${LIBRARY_PATH:+:$LIBRARY_PATH}'';

  programs = {
    java.enable = true;
  };
}
