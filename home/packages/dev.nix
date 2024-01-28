{ pkgs
, inputs
, ...
}: {
  home.packages = with pkgs; [
    tree-sitter
    lua-language-server

    delve
    go
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools
    gotest
    gofumpt
    mockgen

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

    bun
    nodejs
    yarn
    nodePackages.typescript-language-server

    openssl
    pkg-config

    python312
    pipenv
    pyenv

    nixd

    foundry-bin
    nodePackages.ganache
    (inputs.solc.mkDefault pkgs pkgs.solc_0_8_23)
  ];
}
