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
    ./java.nix
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
    stdenv # TODO: is this needed?
    taplo
    taplo-lsp
    tree-sitter
    vscode-langservers-extracted
    wgsl-analyzer
    yamlfmt
    zizmor
    codespell
  ];

  home.sessionVariables.LIBRARY_PATH = ''${lib.makeLibraryPath [pkgs.libiconv]}''${LIBRARY_PATH:+:$LIBRARY_PATH}'';
}
