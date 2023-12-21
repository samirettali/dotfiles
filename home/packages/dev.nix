{ pkgs, ... }: {
  home.packages = with pkgs; [
    tree-sitter
    lua-language-server

    go
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools

    # cmake
    # gcc
    # gnumake
    # clang-tools
    # gnuplot

    # libiconv
    # nodejs
    # openssl
    # pkg-config

    lua-language-server
    # docker-compose # TODO check
    nodejs
    openssl
    pipenv
    pkg-config
    pkgs.tree-sitter
    python312
    pipenv

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
