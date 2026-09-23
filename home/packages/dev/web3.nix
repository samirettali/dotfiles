{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.features.web3 [
      foundry
      go-ethereum
      slither-analyzer
      solc-select
      vscode-solidity-server
    ];
}
