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

    openssl.dev
    pkg-config

    python312
    pipenv
    pyenv

    nixpkgs-fmt
    nixd

    foundry-bin
    (inputs.solc.mkDefault pkgs pkgs.solc_0_8_23)

    gh
    kcat
  ];
}
