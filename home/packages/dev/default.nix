{
  lib,
  pkgs,
  nurPkgs,
  inputs,
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
    ./web3.nix
    ./zig.nix
    ./dart.nix
  ];

  home.packages = with pkgs; [
    # ast-grep
    # lld # TODO: needed?
    # stdenv # TODO: is this needed?
  ];

  programs.codex = {
    enable = lib.mkDefault false;
    package = nurPkgs.codex;
    skills = import ../shell/coding-agent-skills.nix {inherit inputs;};
  };
}
