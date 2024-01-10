{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    tree-sitter
    lua-language-server

    go
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools
    gotest
    gofumpt

    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
    cargo-watch

    cmake
    gcc
    gnumake
    clang-tools
    stdenv

    nodejs
    nodePackages.typescript-language-server

    openssl
    pkg-config

    python312
    pipenv
    pyenv

    rnix-lsp
  ];
}

