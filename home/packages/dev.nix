{ pkgs, ... }: {
  home.packages = with pkgs; [
    tree-sitter
    lua-language-server

    go
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools

    cmake
    gcc
    gnumake
    clang-tools
    stdenv

    # libiconv
    # nodejs
    # openssl
    # pkg-config

    nodejs
    nodePackages.typescript-language-server

    openssl
    pkg-config

    python312
    pipenv
    pyenv

    rnix-lsp

    (fenix.combine [
      (fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      fenix.targets.wasm32-unknown-unknown.latest.rust-std
    ])
    bunyan-rs
    cargo-nextest
    cargo-shuttle
    cargo-watch
    rust-analyzer-nightly
    sqlx-cli
    trunk
  ];
}
