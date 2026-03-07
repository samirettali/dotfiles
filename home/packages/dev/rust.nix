{
  pkgs,
  lib,
  config,
  features,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals features.rust [
      lldb # debugging
      cargo-geiger
      libiconv
      (rust-bin.stable.latest.default.override
        {
          extensions = [
            "clippy"
            "rust-src"
            "rust-analyzer"
          ];
          targets = lib.optionals pkgs.stdenv.isLinux ["x86_64-unknown-linux-gnu"]; # TODO: is this needed?
        })
    ];

  home.sessionVariables = lib.optionalAttrs features.rust {
    LIBRARY_PATH = ''${lib.makeLibraryPath [pkgs.libiconv]}''${LIBRARY_PATH:+:$LIBRARY_PATH}'';
  };

  programs.vscode.profiles.default =
    lib.optionalAttrs features.rust
    {
      extensions = pkgs.nix4vscode.forVscodeVersion config.programs.vscode.package.version [
        "rust-lang.rust-analyzer"
      ];
    };
}
