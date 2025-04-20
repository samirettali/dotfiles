{pkgs, ...}: {
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
    stdenv
    tree-sitter
    vscode-langservers-extracted
    zizmor
  ];

  programs = {
    java.enable = true;
  };
}
