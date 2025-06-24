{
  lib,
  pkgs,
  ...
}: let
  wgsl-analyzer = import ./wgsl-analyzer.nix {inherit lib pkgs;};
in {
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
    lld
    lldb # for rust debugging
    stdenv
    tree-sitter
    vscode-langservers-extracted
    wgsl-analyzer
    yamlfmt
    zizmor
  ];

  home.sessionVariables.LIBRARY_PATH = ''${lib.makeLibraryPath [pkgs.libiconv]}''${LIBRARY_PATH:+:$LIBRARY_PATH}'';

  programs = {
    java.enable = true;
  };
}
