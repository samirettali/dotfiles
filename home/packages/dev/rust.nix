{
  pkgs,
  lib,
  config,
  features,
  ...
}: {
  programs.cargo = {
    enable = features.rust;
    # targets = lib.optionals pkgs.stdenv.isLinux ["x86_64-unknown-linux-gnu"]; # TODO: is this needed?
  };

  home.packages = with pkgs;
    lib.optionals features.rust [
      rust-analyzer
      rustc
      rustfmt
      clippy
      lldb # debugging
      cargo-geiger
      libiconv
    ];

  home.sessionVariables = lib.optionalAttrs features.rust {
    LIBRARY_PATH = ''${lib.makeLibraryPath [pkgs.libiconv]}''${LIBRARY_PATH:+:$LIBRARY_PATH}'';
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };

  programs.vscode.profiles.default =
    lib.optionalAttrs features.rust
    {
      extensions = pkgs.nix4vscode.forVscodeVersion config.programs.vscode.package.version [
        "rust-lang.rust-analyzer"
      ];
    };
}
