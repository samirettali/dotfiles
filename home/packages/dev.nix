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

    air
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

    cargo
    clippy
    rustc
    rustfmt
    cargo-watch
    cargo-generate
    rust-analyzer

    cmake
    gcc
    gnumake
    clang-tools
    stdenv

    bun
    nodejs
    yarn
    nodePackages.typescript-language-server
    nodePackages.prettier
    prettierd
    # nodePackages.eslint
    # eslint_d

    stylua
    lua-language-server

    python312
    pipenv
    pyenv
    pyright
    isort
    black

    alejandra
    nixd

    zig
    zls

    bash-language-server
    shellcheck
    shfmt

    htmx-lsp

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
