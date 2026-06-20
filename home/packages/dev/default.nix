{pkgs, ...}: {
  imports = [
    ./c.nix
    ./codex.nix
    ./go.nix
    ./js.nix
    ./lua.nix
    ./nix.nix
    ./python.nix
    ./rust.nix
    ./java.nix
    ./web3.nix
    ./zig.nix
    ./dart.nix
  ];

  home.packages = with pkgs; [
    # ast-grep
    # lld # TODO: needed?
    # stdenv # TODO: is this needed?
  ];
}
