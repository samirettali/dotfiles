{
  pkgs,
  lib,
  config,
  ...
}: let
  rustPkgs =
    pkgs.rust-bin.stable.latest.default.override
    {
      extensions = [
        "clippy"
        "rust-src"
        "rust-analyzer"
      ];
      targets = ["x86_64-unknown-linux-gnu"];
    };
in {
  home.packages = [
    rustPkgs
    pkgs.cargo-geiger
  ];

  programs.vscode.profiles.default =
    lib.optionals (
      builtins.elem
      rustPkgs
      config.home.packages
    ) {
      extensions = pkgs.nix4vscode.forVscodeVersionPrerelease config.programs.vscode.package.version [
        "rust-lang.rust-analyzer"
      ];
    };
}
