{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    ast-grep
    tree-sitter

    # TODO: check if needed
    pkg-config
    openssl.dev
    libiconv

    delve
    go
    gopls
    golangci-lint
    golangci-lint-langserver
    gotools
    gotest
    gofumpt
    mockgen
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    revive

    (fenix.combine [
      (fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rustc"
        "rust-docs"
        "rustfmt"
        "rust-src"
        "rust-std"
      ])
      fenix.targets.wasm32-unknown-unknown.latest.rust-std
    ])
    cargo-watch
    cargo-generate
    rust-analyzer-nightly
    wasm-pack

    cmake
    gcc
    gnumake
    clang-tools
    stdenv

    bun
    nodejs
    yarn
    nodePackages.typescript-language-server

    stylua
    lua-language-server

    python312
    pipenv
    pyenv
    pyright

    alejandra
    nixd

    zig
    zls

    foundry-bin
    # (inputs.solc.mkDefault pkgs pkgs.solc_0_8_25)
    solc-select
    slither-analyzer
    go-ethereum
    # nur.repos.gabr1sr.vscode-solidity-server
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.yarn/bin"
  ];
}
