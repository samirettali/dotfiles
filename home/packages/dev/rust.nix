{
  pkgs,
  lib,
  config,
  features,
  ...
}: {
  home.packages = lib.optionals features.rust [
    pkgs.cargo-geiger
    (pkgs.rust-bin.stable.latest.default.override
      {
        extensions = [
          "clippy"
          "rust-src"
          "rust-analyzer"
        ];
        targets = lib.optionals pkgs.stdenv.isLinux ["x86_64-unknown-linux-gnu"]; # TODO: is this needed?
      })
  ];

  programs.vscode.profiles.default =
    lib.optionalAttrs features.rust
    {
      extensions = pkgs.nix4vscode.forVscodeVersion config.programs.vscode.package.version [
        "rust-lang.rust-analyzer"
      ];
    };
}
