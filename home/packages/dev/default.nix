{pkgs, ...}: {
  import = [
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
    jdk
    stdenv
    tree-sitter
  ];
}
