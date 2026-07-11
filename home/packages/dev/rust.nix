{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.cargo = {
    enable = config.features.rust;
    # targets = lib.optionals pkgs.stdenv.isLinux ["x86_64-unknown-linux-gnu"]; # TODO: is this needed?
  };

  home.packages = with pkgs;
    lib.optionals config.features.rust [
      rust-analyzer
      rustc
      rustfmt
      clippy
      lldb # debugging
      cargo-geiger
      libiconv
    ];

  home.sessionVariables = lib.optionalAttrs config.features.rust {
    LIBRARY_PATH = ''${lib.makeLibraryPath [pkgs.libiconv]}''${LIBRARY_PATH:+:$LIBRARY_PATH}'';
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };

  dotfiles.vscode.extensionIds = lib.optionals config.features.rust [
    "rust-lang.rust-analyzer"
  ];
}
